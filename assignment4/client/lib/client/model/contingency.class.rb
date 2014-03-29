class Contingency < ActiveRecord::Base
	belongs_to :project
	
	def relevant?
		(commit_passed >= 5) and (commit_failed >= 5) and (pr_passed >= 5) and (pr_failed >= 5)
	end
	
	def self.relevant?
		"commit_passed >= 5 AND commit_failed >= 5 AND pr_passed >= 5 AND pr_failed >= 5"
	end
end
