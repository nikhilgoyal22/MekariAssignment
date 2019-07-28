require 'rails_helper'

RSpec.describe "employees/index", :type => :view do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
    assign(:employees, [
      Employee.create!(
        :name => "Name",
        :email => "Email",
        :phone => "123",
        :company => @company
      ),
      Employee.create!(
        :name => "Name2",
        :email => "Email2",
        :phone => "456",
        :company => @company
      )
    ])
  end

  it "renders a list of employees" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 1
    assert_select "tr>td", :text => "Name2".to_s, :count => 1
    assert_select "tr>td", :text => "Email".to_s, :count => 1
    assert_select "tr>td", :text => "Email2".to_s, :count => 1
    assert_select "tr>td", :text => "123".to_s, :count => 1
    assert_select "tr>td", :text => "456".to_s, :count => 1
    assert_select "tr>td", :text => @company.to_s, :count => 2
  end
end
