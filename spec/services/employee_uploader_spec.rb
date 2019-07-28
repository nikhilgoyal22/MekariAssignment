require 'rails_helper'

RSpec.describe EmployeeUploader do

  def file_path(filename)
    File.join(Rails.root, 'spec', 'fixtures', filename)
  end

  describe "employee uploader service" do
    before(:each) do
      @company = Company.create!(name: 'Test Company')
      expect(Employee.count).to be(0)
    end

    it "does not uploads empty file" do
      file = File.open(file_path('empty_sample.csv'))
      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(false)
      expect(Employee.count).to be(0)
      expect(errors).to eq({file: 'File is empty'})
    end

    it "uploads valid file" do
      file = File.open(file_path('valid_sample.csv'))
      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(true)
      expect(Employee.count).to be(3)
    end

    it "no extra employees persisted if same file uploaded again" do
      file = File.open(file_path('valid_sample.csv'))
      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(true)
      expect(Employee.count).to be(3)

      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(false)
      expect(Employee.count).to be(3)
      expect(errors.keys.sort).to eq([1, 2, 3])
      [1, 2, 3].each {|i| expect(errors[i]).to eq("Email has already been taken")}
    end

    it "upload fails if any cyclic dependency" do
      file = File.open(file_path('cyclic_dependency.csv'))
      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(false)
      expect(Employee.count).to be(0)
      expect(errors).to eq({cyclic: 'cyclic dependency found between: ["bob@example.com", "jon@example.com", "arya@example.com"]'})
    end

    it "no employees persisted for invalid file" do
      file = File.open(file_path('invalid_sample1.csv'))
      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(false)
      expect(Employee.count).to be(0)
      expect(errors.keys.sort).to eq([1, 2, 3])
      expect(errors[1]).to eq("Invalid Manager")
      expect(errors[2]).to eq("Email can't be blank")
      expect(errors[3]).to eq("Invalid Manager")
    end

    it "no employees persisted if file is partially correct" do
      file = File.open(file_path('invalid_sample2.csv'))
      success, errors = EmployeeUploader.new(file, @company).upload
      expect(success).to be(false)
      expect(Employee.count).to be(0)
      expect(errors.keys.sort).to eq([2, 3])
      expect(errors[2]).to eq("Phone is not a number")
      expect(errors[3]).to eq("Invalid Manager")
    end
  end
end
