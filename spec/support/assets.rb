RSpec.configure do |config|
  config.include Module.new do
    def asset_path(file)
      File.join( File.expand_path('../../assets', __FILE__), file )
    end
  end#, :type => :all
end
