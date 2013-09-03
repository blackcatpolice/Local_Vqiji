json.id @session.id
json.html json.partial!(partial: 'talk/sessions/session', formats: [ :html ], locals: { session: @session })
