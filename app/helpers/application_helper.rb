# encoding: utf-8
module ApplicationHelper
  include Rt::RenderHelper
  
  def title
    content_for?(:title) ? content_for(:title) : '川航云平台'
  end
  
  #	<%= truncate(strip_tags("#{@frule.content}").delete!("&nbsp;"), :length => 85) %>
  #从富文本内容截取字符串问题并且过滤特殊字符
  def sub_string(content, strArray, length)
  	 if content.include?(strArray)
  	 		truncate(strip_tags(content).delete!(strArray), :length => length)
  	 else
	 			truncate(strip_tags(content), :length => length)
  	 end
  end
  
  def incognito_avatar_tag(xx)
    raw image_tag("defaults/user/#{xx}_incognito.png")
  end
  
  def truncate_u(text, length = 30, truncate_string = "...")
    l=0
    char_array=text.unpack("U*")
    char_array.each_with_index do |c,i|
      l = l+ (c<127 ? 0.5 : 1)
      if l>length
        return char_array[0..i].pack("U*")+(i ? truncate_string : "")
      end
    end
    return text
  end
  
  
  def disk_file_icon(name, encrypt = false)
    mime_type = MIME::Types.type_for name
    return raw image_tag("disk_icons/icon_encrypt.png") if encrypt
    unless mime_type.empty?
      text = mime_type.first
      if text.media_type == "image"
        return raw image_tag("disk_icons/icon_jpg.png")
      elsif text.media_type == "audio"
        return raw image_tag("disk_icons/icon_audio.png")
      elsif text.media_type == "video"
        return raw image_tag("disk_icons/icon_video.png")
      elsif text == "text/plain"
        return raw image_tag("disk_icons/icon_txt.png")
      elsif ["application/vnd.openxmlformats-officedocument.wordprocessingml.document", "application/msword", "application/word", "application/x-msword", "application/x-word", "text/plain"].include?(text)
        return raw image_tag("disk_icons/icon_doc.png")
      elsif ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/vnd.ms-excel", "application/excel"].include?(text)
        return raw image_tag("disk_icons/icon_xls.png")
      elsif ["application/vnd.openxmlformats-officedocument.presentationml.presentation", "application/vnd.ms-powerpoint", "application/powerpoint"].include?(text)
        return raw image_tag("disk_icons/icon_ppt.png")
      elsif text == "application/pdf"
          return raw image_tag("disk_icons/icon_pdf.png")
      end
    end
    return raw image_tag("disk_icons/icon_file.png")
  end
  
  def get_age_by_id_number id_number
    return 0 if id_number.blank? || id_number[6,4].blank? || id_number[10,2].blank? || id_number[12, 2].blank?
    
    begin
      birthday = Time.new(id_number[6,4], id_number[10,2], id_number[12, 2])
      now = Time.now
    
      unless now <= birthday
        return now.year - birthday.year if now.month > birthday.month && now.day > birthday.day
        return now.year - birthday.year - 1
      end
    rescue
    end
    return 0
  end

end
