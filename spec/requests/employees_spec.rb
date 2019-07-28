require 'rails_helper'

RSpec.describe "Employees", :type => :request do

  def file_path(filename)
    File.join(Rails.root, 'spec', 'fixtures', filename)
  end

  describe "GET /employees" do
    it "works! (now write some real specs)" do
      get employees_path
      expect(response.status).to be(200)
    end
  end

  describe "POST /employees/upload" do
    before(:each) do
      @company = Company.create!(name: 'Test Company')
      expect(Employee.count).to be(0)
    end

    it "fails and gives no file message" do
      params = {file: nil, company: @company.id}
      post upload_employees_path, params: params
      expect(response.status).to be(200)
      expect(Employee.count).to be(0)
      expect(flash[:notice]).to eq("Please provide a csv file")
    end

    it "fails and gives no company message" do
      file = fixture_file_upload(file_path('valid_sample.csv'), 'text/csv')
      params = {file: file, company: nil}
      post upload_employees_path, params: params
      expect(response.status).to be(200)
      expect(Employee.count).to be(0)
      expect(flash[:notice]).to eq("Please select a valid company")
    end

    it "uploads valid file" do
      file = fixture_file_upload(file_path('valid_sample.csv'), 'text/csv')
      params = {file: file, company: @company.id}
      post upload_employees_path, params: params
      expect(response.status).to be(200)
      expect(Employee.count).to be(3)
    end

    it "no employees persisted for invalid file" do
      file = fixture_file_upload(file_path('invalid_sample1.csv'), 'text/csv')
      params = {file: file, company: @company.id}
      post upload_employees_path, params: params
      expect(response.status).to be(200)
      expect(Employee.count).to be(0)
    end
  end
end
