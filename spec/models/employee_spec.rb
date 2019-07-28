require 'rails_helper'

RSpec.describe Employee, :type => :model do
  before(:each) do
    @company = Company.create!(name: 'Test Company')
  end

  let(:valid_attributes) { {name: 'Test', email: 'test@example.com', company: @company} }

  it "is not valid without a name" do
    employee = Employee.new(valid_attributes.except(:name))
    expect(employee).to_not be_valid
    expect(employee.errors.full_messages).to eq(["Name can't be blank"])
  end

  it "is not valid without email" do
    employee = Employee.new(valid_attributes.except(:email))
    expect(employee).to_not be_valid
    expect(employee.errors.full_messages).to eq(["Email can't be blank"])
  end

  it "is not valid without company" do
    employee = Employee.new(valid_attributes.except(:company))
    expect(employee).to_not be_valid
    expect(employee.errors.full_messages).to eq(["Company must exist"])
  end

  it "is not valid with same email" do
    employee = Employee.create(valid_attributes)
    attributes = {name: 'Employee2', email: 'test@example.com', company: @company}
    employee = Employee.new(attributes)
    expect(employee).to_not be_valid
    expect(employee.errors.full_messages).to eq(["Email has already been taken"])
  end

  it "is not valid when phone is made of other than numbers" do
    employee = Employee.new(valid_attributes.merge(phone: 'abc'))
    expect(employee).to_not be_valid
    expect(employee.errors.full_messages).to eq(["Phone is not a number"])
  end

  it "is valid with valid attributes" do
    employee = Employee.new(valid_attributes.merge(phone: 123))
    expect(employee).to be_valid
  end
end
