json.(@user, :id)
json.followed (((_followship = current_user.followed(@user)) && _followship.follow_type) || false)
json.is_fan @user.following?(current_user, true)
