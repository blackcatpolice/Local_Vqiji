class CreateQuestionTypes < Mongoid::Migration
  def self.up
    question_types = [
      {
        :name => '医疗咨询',
        :priority => '0',
        :status => 1,
        :display => true
      },{
        :name => '心理咨询',
        :priority => '1',
        :status => 1,
        :display => true
      },{
        :name => '法律咨询',
        :priority => '2',
        :status => 1,
        :display => false
      },{
        :name => '营养咨询',
        :priority => '3',
        :status => 1,
        :display => false
      },{
        :name => '运动板块',
        :priority => '4',
        :status => 1,
        :display => false
      }
    ]

    question_types.each do |type|
      QuestionType.create type
    end
  end

  def self.down
    QuestionType.destroy_all
  end
end
