require 'csv'
require 'tsort'

class EmployeeUploader
  include TSort

  attr_reader :file, :company

  HEADER_NAME = 'Employee Name'.freeze
  HEADER_EMAIL = 'Email'.freeze
  HEADER_PHONE = 'Phone'.freeze
  HEADER_POLICIES = 'Assigned Policies'.freeze
  HEADER_MANAGER = 'Report To'.freeze

  def initialize(file, company)
    @file = file
    @company = company
    @data = {}
    @all_policies = []
    @errors = {}
    @persisted = []
    @dependency_map = Hash.new{|h, k| h[k] = []}
  end

  def add_dependency(employee, manager)
    @dependency_map[employee] = [manager]
  end

  def tsort_each_node(&block)
    @dependency_map.each_key(&block)
  end

  def tsort_each_child(name, &block)
    @dependency_map[name].each(&block) if @dependency_map.key?(name)
  end

  def upload
    prepare_data
    return [false, {file: 'File is empty'}] if @data.empty? && @errors.empty?
    return [false, @errors, @persisted] if @data.empty?

    sorted_emails = sort_dependency_map
    return [false, @errors, @persisted] if sorted_emails.empty?

    result = validate_and_persist(sorted_emails)
    [result, @errors, @persisted]
  end

  private

  def validate_row(row)
    line_num = row.delete(:line_num)
    employee = Employee.new(row)
    @errors[line_num] = employee.errors.full_messages.join(', ') unless (valid = employee.valid?)
    valid
  end

  def process_valid_row(row)
    if validate_row(row.except(:manager, :policies))
      add_dependency(row[:email], row[:manager]) unless row[:manager].nil?
      @data[row[:email]] = row
    end
  end

  def prepare_data
    CSV.foreach(@file.path, headers: true).with_index do |row, i|
      @all_policies << policies = row[HEADER_POLICIES].split('|').reject(&:empty?)
      obj = {name: row[HEADER_NAME], email: row[HEADER_EMAIL], phone: row[HEADER_PHONE],
             company_id: @company.id, manager: row[HEADER_MANAGER], policies: policies, line_num: i + 1}
      process_valid_row(obj)
    end
  end

  def sort_dependency_map
    tsort
  rescue TSort::Cyclic => e
    @errors[:cyclic] = e.message.gsub('topological sort failed', 'cyclic dependency found between')
    @data.each do |_email, row|
      validate_row(row.except(:policies, :manager))
    end
    []
  end

  def create_employee(line_num, employee, parent_id)
    policy_ids = Policy.where(name: employee.delete(:policies), company_id: @company.id).pluck(:id)
    employee = Employee.create(employee.merge(parent_id: parent_id, policy_ids: policy_ids))
    if employee.persisted?
      @data[employee.email] = employee
      @persisted << employee.id
    else
      @errors[line_num] = employee.errors.full_messages.join(', ')
      @data[employee.email] = nil
    end
  end

  def save_new_employee(employee)
    line_num = employee.delete(:line_num)
    manager = employee.delete(:manager)
    @data[manager] ||= Employee.find_by(email: manager, company_id: @company.id) unless manager.nil?
    if manager.nil? || !(parent_id = @data[manager]&.id).nil?
      create_employee(line_num, employee, parent_id)
    else
      @errors[line_num] = "Invalid Manager"
      @data[employee[:email]] = nil
    end
  end

  def create_policies
    policies = @all_policies.flatten.uniq
    db_policies = Policy.where(name: policies, company_id: @company.id).pluck(:name)
    policies_to_create = (policies - db_policies).map{|name| {name: name, company_id: @company.id, skip: true}}
    Policy.create(policies_to_create)
  end

  def validate_and_persist(sorted_emails)
    ActiveRecord::Base.transaction do
      create_policies
      sorted_emails.each do |email|
        save_new_employee(@data[email]) unless @data[email].nil?
      end
      raise ActiveRecord::Rollback unless @errors.empty?
    end
    @persisted = [] unless @errors.empty?
    @errors.empty?
  end
end
