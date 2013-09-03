class DepartmentCell < Cell::Rails

  def select(args)
  	@tops = Department.top_scope
  	@id = args[:id] || ""
  	@default = args[:default] || false
  	@level = args[:level] || 2
  	@name = args[:name] || ""
  	@select = args[:select] || nil
    render
  end

end
