module Export
	class CSVExporter
		def initialize filename
			@filename = filename
		end
		
		def export all = true
			contingencies = []
			if all
				contingencies = Contingency.all
			else
				contingencies = Contingency.where(Contingency.relevant?)
			end
		
			CSV.open(@filename, "wb", :write_headers => true, :headers => headers) do |csv|
				contingencies.each do |contingency|
					csv << [
						contingency.project.ghtorrentid,
						contingency.project.owner,
						contingency.project.name,
						contingency.commit_passed,
						contingency.commit_failed,
						contingency.pr_passed,
						contingency.pr_failed,
						contingency.relevant?,
						contingency.project.travisid,
						contingency.project.nr_contributors,
						contingency.project.nr_changes,
						contingency.project.age,
						contingency.project.lang
					]
				end
			end
		end
		
		def headers
			["ghtorrent_id", "owner", "name", "commit_passed", "commit_failed", "pr_passed", "pr_failed", "relevant", "travis_id", "nr_contributors", "nr_changes", "age", "lang"]
		end
	end
end
