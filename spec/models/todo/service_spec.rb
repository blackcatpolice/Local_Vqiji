require 'spec_helper'

describe Todo::Service do

	before(:all) do
		@service = Todo::Service.new(@user)
	end

	it "new task" do
		task = @service.new_task
	end
end
