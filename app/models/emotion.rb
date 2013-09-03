# encoding: utf-8

class Emotion
  @emotions = {}
  module ClassMethods  
    def set(emotion, url)
      @emotions[emotion] = url
    end
    
    def each(&block)
      @emotions.each do |k, v|
        yield(k, v)
      end
    end
    
    def url(emotion)
      @emotions[emotion]
    end

    def exists?(emotion)
      @emotions.has_key?(emotion)
    end
    
    def as_json(options)
      @emotions.as_json(options)
    end
  end
  
  self.extend ClassMethods
end


# loading emotions
include Sprockets::Helpers::RailsHelper
include Sprockets::Helpers::IsolatedHelper

{
  '织' => 'e/zz2.gif',
  '神马' => 'e/horse2.gif',
  '浮云' => 'e/fuyun.gif',
  '给力' => 'e/geili.gif',
  '围观' => 'e/wg.gif',
  '威武' => 'e/vw.gif',
  '熊猫' => 'e/panda.gif',
  '兔子' => 'e/rabbit.gif',
  '奥特曼' => 'e/otm.gif',
  '囧' => 'e/j.gif',
  '互粉' => 'e/hufen.gif',
  '礼物' => 'e/liwu.gif',
  '呵呵' => 'e/smilea.gif',
  '嘻嘻' => 'e/tootha.gif',
  '哈哈' => 'e/laugh.gif',
  '可爱' => 'e/tza.gif',
  '可怜' => 'e/kl.gif',
  '挖鼻屎' => 'e/kbsa.gif',
  '吃惊' => 'e/cj.gif',
  '害羞' => 'e/shamea.gif',
  '挤眼' => 'e/zy.gif',
  '闭嘴' => 'e/bz.gif',
  '鄙视' => 'e/bs2.gif',
  '爱你' => 'e/lovea.gif',
  '泪' => 'e/sada.gif',
  '偷笑' => 'e/heia.gif',
  '亲亲' => 'e/qq.gif',
  '生病' => 'e/sb.gif',
  '太开心' => 'e/mb.gif',
  '懒得理你' => 'e/ldln.gif',
  '右哼哼' => 'e/yhh.gif',
  '左哼哼' => 'e/zhh.gif',
  '嘘' => 'e/x.gif',
  '衰' => 'e/cry.gif',
  '委屈' => 'e/wq.gif',
  '吐' => 'e/t.gif',
  '打哈气' => 'e/k.gif',
  '抱抱' => 'e/bba.gif',
  '怒' => 'e/angrya.gif',
  '疑问' => 'e/yw.gif',
  '馋嘴' => 'e/cza.gif',
  '拜拜' => 'e/88.gif',
  '思考' => 'e/sk.gif',
  '汗' => 'e/sweata.gif',
  '困' => 'e/sleepya.gif',
  '睡觉' => 'e/sleepa.gif',
  '钱' => 'e/money.gif',
  '失望' => 'e/sw.gif',
  '酷' => 'e/cool.gif',
  '花心' => 'e/hsa.gif',
  '哼' => 'e/hatea.gif',
  '鼓掌' => 'e/gza.gif',
  '晕' => 'e/dizzya.gif',
  '悲伤' => 'e/bs.gif',
  '抓狂' => 'e/crazya.gif',
  '黑线' => 'e/h.gif',
  '阴险' => 'e/yx.gif',
  '怒骂' => 'e/nm.gif',
  '心' => 'e/hearta.gif',
  '伤心' => 'e/unheart.gif',
  '猪头' => 'e/pig.gif',
  'ok' => 'e/ok.gif',
  '耶' => 'e/ye.gif',
  'good' => 'e/good.gif',
  '不要' => 'e/no.gif',
  '赞' => 'e/z2.gif',
  '来' => 'e/come.gif',
  '弱' => 'e/sad.gif',
  '蜡烛' => 'e/lazu.gif',
  '钟' => 'e/clock.gif',
  '蛋糕' => 'e/cake.gif',
  '话筒' => 'e/m.gif'
}.each do |k, v|
  Emotion.set(k , asset_path(v))
end
