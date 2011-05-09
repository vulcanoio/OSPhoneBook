require File.dirname(__FILE__) + '/../test_helper'

class CompanyTest < ActiveSupport::TestCase
  test "create company" do
    company = Company.create(:name => "Placebo S.A.")
    assert company.valid?
    assert !company.new_record?
  end

  test "try to create company without name" do
    company = Company.create(:name => nil)
    assert_equal "Name can't be blank", company.errors.full_messages.join(", ")
  end

  test "try to repeat company name" do
    company = Company.create(:name => "Placebo S.A.")
    assert company.valid?
    assert !company.new_record?
    company = Company.create(:name => "Placebo S.A.")
    assert_equal "Name has already been taken", company.errors.full_messages.join(", ")
  end
end
