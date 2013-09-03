# encoding: utf-8

# 用户消息
class Talk::Message::User < Talk::Message
  TEXT_MAXLEN = 140

  field :text
  belongs_to :sender, class_name: 'User'

  embeds_many :rtext, class_name: 'Rt::Token'
  embeds_one :picture,  class_name: 'Attachment::Picture'
  embeds_one :audio,  class_name: 'Attachment::Audio'
  embeds_one :file, class_name: 'Attachment::Base'

  has_many :feeds, class_name: 'Talk::Feed', inverse_of: :message, dependent: :destroy
  
  attr_readonly :text, :sender, :rtext, :picture, :audio, :file

  # validations
  validates_presence_of :sender, on: :create
  validates :text, text_length: { maximum: TEXT_MAXLEN }, allow_nil: true, on: :create
  
  # indexes
  index :sender_id => 1
  
  # scopes
  default_scope desc(:created_at)
  
  before_create do |message|
    message.rtext = Talk::Rtext.tokenize(message.text)
  end

  def set_picture(picture_id)
    _picture = Attachment::Picture.get(picture_id)
    if _picture
      _picture.update_attributes(:target => self)
      self.picture = _picture
    end
  end

  def set_audio(audio_id)
    _audio = Attachment::Audio.get(audio_id)
    if _audio
      _audio.update_attributes(:target => self)
      self.audio = _audio
    end
  end

  def set_file(file_id)
    _file = Attachment::Base.get(file_id)
    if _file
      _file.update_attributes(:target => self) if _file.is_a?(Attachment::File)
      self.file = _file
    end
  end
  
  def rtext_html
    @rtext_html ||= Rt::RenderHelper.render_rtext(rtext)
  end
  
  protected
  
  def dispatch_expect_user_ids
    [ sender_id ]
  end
  
  def dispatch_readed_user_ids
    [ sender_id ]
  end
end
