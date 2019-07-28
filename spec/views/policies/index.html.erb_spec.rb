require 'rails_helper'

RSpec.describe "policies/index", :type => :view do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
    assign(:policies, [
      Policy.create!(
        :name => "Name",
        :company => @company
      ),
      Policy.create!(
        :name => "Name2",
        :company => @company
      )
    ])
  end

  it "renders a list of policies" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 1
    assert_select "tr>td", :text => "Name2".to_s, :count => 1
  end
end
