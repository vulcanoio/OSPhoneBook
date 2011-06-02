require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../asterisk_mockup_server'
require 'asterisk_monitor'
require 'asterisk_monitor_config'
require 'gserver'

class AsteriskControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "dial" do
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id
    assert_redirected_to root_path
    assert_equal "Your call is now being completed.", flash[:notice]
  end

  test "dial with XmlHttpRequest" do
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    xhr :get, :dial, :id => phone_number.id
    assert_response :success
    assert_equal "Your call is now being completed.", @response.body
  end

  test "dial to inexistend phone number" do
    get :dial, :id => 9999
    assert_response :not_found
  end

  test "dial without extension to sign in user" do
    users(:admin).extension = nil
    users(:admin).save!
    users(:admin).reload
    assert_nil users(:admin).extension

    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id
    assert_redirected_to root_path
    assert_equal "You can't dial because you do not have an extension set to your user account.", flash[:notice]
  end

  test "dial without sign in" do
    sign_out users(:admin)
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id
    assert_redirected_to new_user_session_path
    assert_nil assigns(:phone_number)
  end

  test "lookup number" do
    contact = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe", @response.body
  end

  test "lookup number with company" do
    contact = Contact.new(:name => "Jane Doe")
    contact.company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe - ULTRA Corp.", @response.body
  end

  test "lookup number with unknown number" do
    PhoneNumber.delete_all
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Unknown", @response.body
  end

  test "lookup number with more than one contact, same company returns company" do
    contact1 = Contact.new(:name => "Jane Doe")
    company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    contact1.company = company
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact1.phone_numbers = [PhoneNumber.new(hash)]
    contact2 = Contact.new(:name => "John Doe")
    contact2.company = company
    contact2.phone_numbers = [PhoneNumber.new(hash)]
    Contact.delete_all
    contact1.save!
    contact2.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "ULTRA Corp.", @response.body
  end

  test "lookup number with more than one contact, different company returns error" do
    contact1 = Contact.new(:name => "Jane Doe")
    contact1.company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact1.phone_numbers = [PhoneNumber.new(hash)]
    contact2 = Contact.new(:name => "John Doe")
    contact2.company = Company.create!(default_hash Company, :name => "MEGA Corp.")
    contact2.phone_numbers = [PhoneNumber.new(hash)]
    Contact.delete_all
    contact1.save!
    contact2.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "ERROR: duplicated number", @response.body
  end

  test "lookup number without number" do
    PhoneNumber.delete_all
    get :lookup
    assert_response :success
    assert_equal "Unknown", @response.body
  end

  test "lookup number without sign in" do
    sign_out users(:admin)
    contact = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe", @response.body
  end

  test "dial route" do
    assert_routing(
      {:method => :get, :path => '/dial/1'},
      {:controller => 'asterisk', :action => 'dial', :id => "1"}
    )
  end

  test "call id lookup route" do
    assert_routing(
      {:method => :get, :path => '/callerid_lookup'},
      {:controller => 'asterisk', :action => 'lookup'}
    )
  end
end
