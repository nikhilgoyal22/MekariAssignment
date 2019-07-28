require 'rails_helper'

RSpec.describe "policies/show", :type => :view do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
    @policy = assign(:policy, Policy.create!(
      :name => "Name",
      :company => @company
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(//)
  end
end
