# encoding: utf-8
module Store::ProductsHelper
  # 常量初始化的 款式选项
  STYLE_OPTIONS = ["颜色","大小","材料","风格"]
  
  # 所有一级商品类型,创建和编辑商品分类时使用
  def product_type_base_help pty
    options = "<option value=''>默认</option><option disabled='disabled' value=''>--------</option>";
    types = Store::ProductType.base_scope
    types.each do |type|
      select = "selected='selected'" if pty.parent == type.name;
      options = options+"<option value='#{type.name}' #{select} >#{type.name}</option>" if type.name != pty.name #排除当前类型
    end
    return options.html_safe
  end
  
  # 产品分类 新建和编辑商品时使用
  def product_type_all_help product_type
    options = "";
    types = Store::ProductType.base_scope
    types.each do |type|
      select = "selected='selected'" if product_type == type.name;
      options = options+"<option value='#{type.name}' #{select} >#{type.name}</option>"
      child_types = type.child_types
      child_types.each do |child_type|
        slt = "selected='selected'" if product_type == child_type.name;
        options = options+"<option value='#{child_type.name}' #{slt} >&nbsp;&nbsp;#{child_type.name}</option>"
      end
    end
    return options.html_safe
  end
  
  # 款式选项，创建和编辑商品时使用
  def style_options_help sty
    options = "<option value=''>标题</option>"
    STYLE_OPTIONS.each do |option|
     select = "selected='selected'" if sty == option;
     options = options + "<option value='#{option}' #{select} >#{option}</option>"  
    end
    options = options + "<option disabled='disabled' value=''>--------</option><option value=''>自定义</option>"
    return options.html_safe
  end
end
