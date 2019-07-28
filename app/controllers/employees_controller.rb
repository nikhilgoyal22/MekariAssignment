class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]
  before_action :validate_file_and_company, only: [:upload]

  # GET /employees
  # GET /employees.json
  def index
    @employees = Employee.all
  end

  def file_upload
    @errors = {}
  end

  def upload
    @success, @errors, ids = EmployeeUploader.new(params[:file], @company).upload
    @employees = Employee.where(id: ids).includes(:parent, :company)
    flash[:notice] = "File successfully uploaded" if @success
    render :file_upload
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees
  # POST /employees.json
  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /employees/1
  # PATCH/PUT /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url, notice: 'Employee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_employee
    @employee = Employee.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def employee_params
    params.require(:employee).permit(:name, :email, :phone, :company_id)
  end

  def validate_file_and_company
    @errors = {}
    @file = params[:file]
    @company = Company.find_by(id: params[:company])
    @errors[:file] = 'Please provide a csv file' unless %w[application/vnd.ms-excel text/csv].include?(@file&.content_type)
    @errors[:company] = 'Please select a valid company' if @company.nil?
    flash[:notice] = @errors.blank? ? nil : @errors.values.join(', ')
    render :file_upload unless @errors.blank?
  end
end
