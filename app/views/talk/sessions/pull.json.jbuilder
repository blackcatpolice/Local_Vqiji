@sessions.each do |session|
  json.set! session.id do
    json.(session, :unread_count)
    json.messages session.feeds.unread.limit(30) do |feed|
      json.(feed, :id, :group_id)
      json.created_at l(feed.created_at, format: :short)
      json.sender do
        json.(feed.message.sender, :id, :name)
      end
      json.rtext feed.message.rtext_html
    end
  end
end
