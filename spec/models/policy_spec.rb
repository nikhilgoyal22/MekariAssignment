require 'rails_helper'

RSpec.describe Policy, :type => :model do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
  end

  let(:valid_attributes) { {name: 'Leave', company: @company} }

  it "is not valid without a name" do
    policy = Policy.new(valid_attributes.except(:name))
    expect(policy).to_not be_valid
    expect(policy.errors.full_messages).to eq(["Name can't be blank"])
  end

  it "is not valid without company" do
    policy = Policy.new(valid_attributes.except(:company))
    expect(policy).to_not be_valid
    expect(policy.errors.full_messages).to eq(["Company must exist"])
  end

  it "is not valid with same name in a company" do
    policy = Policy.create(valid_attributes)
    policy2 = Policy.new(valid_attributes)
    expect(policy2).to_not be_valid
    expect(policy2.errors.full_messages).to eq(["Name has already been taken"])
  end

  it "is valid with valid attributes" do
    policy = Policy.new(valid_attributes)
    expect(policy).to be_valid
  end

  it "is valid with same name but different company" do
    policy = Policy.create(valid_attributes)
    company = Company.create!(name: 'Test Company 2')
    policy = Policy.new({name: valid_attributes[:name], company: company})
    expect(policy).to be_valid
  end
end
