module CarrierWave
  module FFMPEG
    extend ActiveSupport::Concern

    module ClassMethods
      def transcode_flv options
        process :transcode_flv => options
      end
    end
    
    #
    # model.file = request.body
    #  1. file uploader.cache!
    #  2. after cache callback:
    #    * processing
    #    * versions uploader.cache!
    # 
    # 转换为 flv 编码
    # ffmpeg -i test.spx -ab 16 -ar 22050 -ac 1 -f flv test.flv
    def transcode_flv
      with_temp_filepath(original_filename) do |temp_path|
        FileUtils.mv current_path, temp_path
        movie = ::FFMPEG::Movie.new(temp_path)
        
        movie.transcode(current_path, "-ab 16 -ar 22050 -ac 1 -f flv")
      end
    rescue RuntimeError => e
      raise CarrierWave::ProcessingError, I18n.translate(:"errors.messages.ffpeg_processing_error", :e => e)
    end

    private
    
    def with_temp_filepath(basename = 'foo')
      tmpfile = Tempfile.new basename
      tmpfile.close
      
      yield tmpfile.path
    ensure
      tmpfile.unlink
    end
  end
end
