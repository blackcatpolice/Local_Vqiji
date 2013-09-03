class CreateWeatherScopes < Mongoid::Migration
  def self.up
    # 以下翻译来自 Google 翻译
    [
      # 一级城市
      [
        %w(北京 上海 广州 深圳 天津),
        %w(Beijing Shanghai Guangzhou Shenzhen Tianjin),
        ', CN'
      ],
    
      # 二级城市
      [
        %w(南京 武汉 沈阳 西安 成都 重庆 杭州 青岛 大连 宁波),
        %w(Nanjing Wuhan Shenyang Xian Chengdu Chongqing Hangzhou Qingdao Dalian Ningbo),
        ', CN'
      ],

      [
        %w(济南 哈尔滨 长春 厦门 郑州 长沙 福州 乌鲁木齐 昆明 兰州 苏州 无锡),
        %w(Jinan Harbin Changchun Xiamen Zhengzhou Changsha Fuzhou Urumqi Kunming Lanzhou Suzhou Wuxi),
        ', CN'
      ],

      [
        %w(南昌 贵阳 南宁 合肥 太原 石家庄 呼和浩特),
        %w(Nanchang Guiyang Nanning Hefei Taiyuan Shijiazhuang Hohhot),
        ', CN'
      ],

      [
        %w(佛山 东莞 唐山 烟台 泉州 包头),
        %w(Foshan Dongguan Tangshan Yantai Quanzhou Baotou),
        ', CN'
      ],

      # 三级城市
      [
        %w(银川 西宁 海口 洛阳 南通 常州 徐州 潍坊 淄博 绍兴 温州 台州 大庆 鞍山 中山 珠海 汕头 吉林 柳州),
        %w(Yinchuan Xining Haikou Luoyang Nantong Changzhou Xuzhou Weifang Zibo Shaoxing Wenzhou Taizhou Daqing Anshan Zhongshan Zhuhai Shantou Jilin Liuzhou),
        ', CN'
      ],

      [
        %w(拉萨 保定 邯郸 秦皇岛 沧州 鄂尔多斯 东营 威海 济宁 临沂 德州 滨州 泰安 湖州 嘉兴 金华 镇江 盐城 扬州 桂林 惠州 湛江 江门 茂名 株洲 岳阳 衡阳 宝鸡 宜昌 襄樊 开封 许昌 平顶山 赣州 九江 芜湖 绵阳 齐齐哈尔 牡丹江 抚顺),
        %w(Lhasa Baoding Handan Qinhuangdao Cangzhou Ordos Dongying Weihai Jining Linyi Dezhou Binzhou Taian Huzhou Jiaxing Jinhua Zhenjiang Yancheng Yangzhou Guilin Zhanjiang Huizhou Jiangmen Maoming Zhuzhou Yueyang Hengyang Baoji Yichang Xiangfan Kaifeng Xuchang Pingdingshan Ganzhou Jiujiang Wuhu Mianyang Qiqihar Mudanjiang Fushun),
        ', CN'
      ],

      [
        %w(本溪 丹东 辽阳 锦州 营口 承德 廊坊 邢台 大同 榆林 延安 天水 克拉玛依 喀什 石河子 南阳 濮阳 安阳 焦作 新乡 日照 聊城 枣庄 蚌埠 淮南 连云港 淮安 丽水 衢州 荆州 安庆 景德镇 新余 湘潭 常德 郴州 漳州 清远 揭阳 梅州 肇庆 北海 德阳 宜宾 遵义 大理),
        %w(Benxi Dandong Liaoyang Jinzhou Yingkou Chengde Langfang Xingtai Datong Yulin Yanan Tianshui Karamay Kashi Shihezi Nanyang Puyang Anyang Jiaozuo Xinxiang sunshine Liaocheng Zaozhuang Bengbu Huainan Lianyungang Huaian Lishui Quzhou Jingzhou Anqing Jingdezhen Xinyu Xiangtan Changde Chenzhou Zhangzhou Qingyuan Jieyang Meizhou Zhaoqing Beihai Deyang Yibin Zunyi Dali),
        ', CN'
      ],

      # 火星城市
      [
        %w(香港 澳门 马鞍山),
        ['Hong Kong', 'Macao', 'Ma On Shan'],
        ''
      ]
    ].each_with_index do |packet, packet_index|
      raise "packet codes not match cities! index: #{ packet_index }" if packet[0].length != packet[1].length
      
      codes = packet[1]
      stuff = packet[2] || ""

      packet[0].each_with_index do |city, city_index|
        begin
          Widget::Weather::Scope.create!(:name => city, :code => "#{ codes[city_index] }#{ stuff }")
        rescue => e
          p ">>> city: #{ city }, code: #{ codes[city_index] }, stuff: #{ stuff }"
          raise e
        end
      end
    end
  rescue => e
    down
    raise e
  end

  def self.down
    Widget::Weather::Scope.destroy_all
  end
end
