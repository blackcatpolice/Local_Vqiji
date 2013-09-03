# encoding: utf-8

module UsersHelper
  def user_tag(user)
  	link_to(user.name, user_path(user), :'data-user-id' => user.to_param)
  end
  
  def format_city(city)
    [city.country, city.province, city.city].compact.join('-') if city
  end
  
  alias :format_address :format_city
  
  # 默认的头像
  def user_default_avater(version = 'v50x50')
  	"defaults/user/#{ [version, 'avatar.png'].compact.join('_') }"
  end
  
  def user_gender_image_path(user)
    (user.gender == User::GENDER_MALE) ? asset_path('male.png') : asset_path('female.png')
  end
  
  def user_department_title(user)
    (user.department && user.department.name) || '<部门未设置>'
  end
  
  def user_job_title(user)
    user.job || '<职位未设置>'
  end
  
  def user_gender(user)
    current_user.gender == User::GENDER_MALE ? '男' : '女'
  end
end
