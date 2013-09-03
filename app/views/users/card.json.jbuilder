json.(@user, :id, :name, :gender, :followeds_count, :fans_count, :tweets_count)
json.avatar_url @user.avatar.v84x84.url
json.department_name (@user.department ? @user.department.name : '<部门未设置>')
json.job (@user.job ? @user.job : '<职位未设置>')
json.followed (((_followship = current_user.followed(@user)) && _followship.follow_type) || false)
json.is_fan @user.following?(current_user, true)
