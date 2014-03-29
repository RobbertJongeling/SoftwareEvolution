class Project < ActiveRecord::Base
	validates :name, presence: true
	validates :owner, presence: true
	
	has_one :contingency
	
	after_initialize :default

	def default
		self.processed ||= false
	end

	def slug
		"#{owner}/#{name}"
	end
	
	def processed?
		return processed
	end
	
	def processed!
		self.processed = true
	end
end
