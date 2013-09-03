# encoding: utf-8
#
# 及时通知
#
class Realtime::Alert < Realtime::Trigger
  attr_reader :title, :body

  def initialize(body, title = nil)
    @body = body
    @title = title || I18n.t('realtime.alert.title')
    super('alert', [@body, @title])
  end
end
