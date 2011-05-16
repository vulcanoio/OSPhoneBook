require File.dirname(__FILE__) + '/../test_helper'

class ContactsControllerTest < ActionController::TestCase
  test "show" do
    contact = Contact.create!(default_hash(Contact))
    get :show, :id => contact.id
    assert_response :success
    assert_template "show"
    assert_equal contact, assigns(:contact)
  end

  test "show with contact without company" do
    contact = Contact.create!(default_hash(Contact))
    contact.company.destroy
    get :show, :id => contact.id
    assert_response :success
    assert_template "show"
    assert_equal contact, assigns(:contact)
  end

  test "show with invalid id" do
    get :show, :id => 99999
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:contact)
  end

  test "edit" do
    contact = Contact.create!(default_hash(Contact))
    get :edit, :id => contact.id
    assert_response :success
    assert_template "edit"
    assert_equal contact, assigns(:contact)
  end

  test "edit with invalid id" do
    get :edit, :id => 99999
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:contact)
  end

  test "update" do
    contact = Contact.create!(default_hash(Contact))
    assert_not_equal "Apolonium", contact.name
    put :update, :id => contact.id, :contact => {:name => "Apolonium"}
    assert_redirected_to root_path
    assert_equal contact, assigns(:contact)
    assert assigns(:contact).valid?
    assert_equal "Apolonium", assigns(:contact).name
  end

  test "update with invalid id" do
    put :update, :id => 99999
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:contact)
  end

  test "show route" do
    assert_routing(
      {:method => :get, :path => '/contacts/1'},
      {:controller => 'contacts', :action => 'show', :id => "1"}
    )
  end

  test "edit route" do
    assert_routing(
      {:method => :get, :path => '/contacts/1/edit'},
      {:controller => 'contacts', :action => 'edit', :id => "1"}
    )
  end

  test "update route" do
    assert_routing(
      {:method => :put, :path => '/contacts/1'},
      {:controller => 'contacts', :action => 'update', :id => "1"}
    )
  end
end
