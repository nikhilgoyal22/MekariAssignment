require 'rails_helper'

RSpec.describe Company, :type => :model do
  it "is not valid without a name" do
    company = Company.new(name: nil)
    expect(company).to_not be_valid
    expect(company.errors.full_messages).to eq(["Name can't be blank"])
  end

  it "is valid with name" do
    company = Company.new(name: 'company')
    expect(company).to be_valid
  end
end
