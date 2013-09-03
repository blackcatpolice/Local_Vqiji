json.array! @sessions do |session|
  json.(session, :id, :group_id, :unread_count)
  json.p2p session._p2p
  json.members_count session.group.sessions_count
  json.title talk_session_title(session)
  json.subtitle talk_session_subtitle(session)
  json.avatar_url talk_session_avatar_url(session)
end
