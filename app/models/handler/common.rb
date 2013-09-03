#
module Handler

	module Common
		def created_at_str
			self.created_at.strftime("%Y-%m-%d %H:%M:%S")
		end
	end
end