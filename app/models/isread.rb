# encoding: utf-8

class Isread
  include Mongoid::Document
  include Mongoid::Timestamps
  
  field :message_id
  field :reader_id, type: Integer
  field :message_type
  
  def self.isread?(mid, rid, mtype) 
  	 where(:message_id => mid.to_s, :reader_id => rid, :message_type => mtype).first
  end
end
