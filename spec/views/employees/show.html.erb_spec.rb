require 'rails_helper'

RSpec.describe "employees/show", :type => :view do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
    @employee = assign(:employee, Employee.create!(
      :name => "Name",
      :email => "Email",
      :phone => "123",
      :company => @company
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Email/)
    expect(rendered).to match(/Phone/)
    expect(rendered).to match(//)
  end
end
