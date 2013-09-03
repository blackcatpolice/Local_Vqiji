json.(@comment, :id, :tweet_id)
json.html json.partial!(:partial => "/tweet/comments/#{ params[:_tmpl] || "comment" }", formats: [ :html ], locals: { comment: @comment })
