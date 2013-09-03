module Admin::ExcelHelper
  def excel_import_errors(excel)
    if excel.import_errors.blank?
      '没有导入错误'
    else
      excel.import_errors.map do |error|
        h error
      end.join('<br/>').html_safe
    end
  end
  
  def excel_import_status(excel)
    if excel.import_errors.blank?
      '导入成功'
    else
      '已导入，但是有错误'
    end
  end
end
