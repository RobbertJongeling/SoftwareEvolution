module Export
	class CSVExporter
		def initialize filename
			@filename = filename
		end
		
		def export
			contingencies = Contingency.where(Contingency.relevant?)
		
			CSV.open(@filename, "wb", :write_headers => true, :headers => headers) do |csv|
				contingencies.each do |contingency|
					csv << [contingency.project.owner, contingency.project.name, contingency.commit_passed, contingency.commit_failed, contingency.pr_passed, contingency.pr_failed]
				end
			end
		end
		
		def headers
			["owner", "name", "commit_passed", "commit_failed", "pr_passed", "pr_failed"]
		end
	end
end
