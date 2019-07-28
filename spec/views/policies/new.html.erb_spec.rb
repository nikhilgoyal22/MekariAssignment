require 'rails_helper'

RSpec.describe "policies/new", :type => :view do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
    assign(:policy, Policy.new(
      :name => "MyString",
      :company => @company
    ))
  end

  it "renders new policy form" do
    render

    assert_select "form[action=?][method=?]", policies_path, "post" do

      assert_select "input#policy_name[name=?]", "policy[name]"

      assert_select "input#policy_company_id[name=?]", "policy[company_id]"
    end
  end
end
