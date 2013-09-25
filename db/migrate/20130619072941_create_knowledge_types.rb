class CreateKnowledgeTypes < Mongoid::Migration
  def self.up
    knowledge_types = [
      {
        :name => '行政',
        :image => 'zsk_01.jpg',
        :priority => '0'
      },
      {
        :name => '空乘',
        :image => 'zsk_03.jpg',
        :priority => '1'
      },
      {
        :name => '飞行',
        :image => 'zsk_06.jpg',
        :priority => '2'
      },
      {
        :name => '地勤',
        :image => 'zsk_05.jpg',
        :priority => '3'
      },
      {
        :name => '市场',
        :image => 'zsk_04.jpg',
        :priority => '4'
      },
      {
        :name => '机务',
        :image => 'zsk_02.jpg',
        :priority => '5'
      }
    ]

    knowledge_types.each do |type|
      Knowledge::KnowledgeType.create(type)
    end
  end

  def self.down
    KnowledgeType.destroy_all
  end
end
