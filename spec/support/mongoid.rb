RSpec.configure do |config|
  config.before(:each) { Mongoid::IdentityMap.clear }
end
