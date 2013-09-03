class Store::Viewed
  
  include Mongoid::Document
  include Mongoid::Timestamps
  belongs_to :product,class_name:'Store::Product'
  
  field :product_id, type: String #
  field :count,type: Integer #浏览次数
  
  def self._create product_id
    view = self.where(:product_id=>product_id).first
    view = self.new if view.nil?
    view.product_id = product_id
    view.count = (view.nil? ? 1 : view.count.to_i + 1)
    view.save
  end
end
