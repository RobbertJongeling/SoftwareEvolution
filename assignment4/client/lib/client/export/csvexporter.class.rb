module Export
	class CSVExporter
		def initialize filename
			@filename = filename
		end
		
		def export
			projects = Project.all
		
			CSV.open(@filename, "wb", :write_headers => true, :headers => headers) do |csv|
				projects.each do |project|
					if project.contingency.nil?
						project.contingency = Contingency.new({
							:commit_passed => 0,
							:commit_failed => 0,
							:pr_passed => 0,
							:pr_failed => 0,
							:project => project
						})
					end
					csv << [
						project.ghtorrentid,
						project.owner,
						project.name,
						project.contingency.commit_passed,
						project.contingency.commit_failed,
						project.contingency.pr_passed,
						project.contingency.pr_failed,
						project.contingency.relevant?,
						project.travisid,
						project.nr_contributors,
						project.nr_changes,
						project.age,
						project.lang
					]
				end
			end
		end
		
		def headers
			["ghtorrent_id", "owner", "name", "commit_passed", "commit_failed", "pr_passed", "pr_failed", "relevant", "travis_id", "nr_contributors", "nr_changes", "age", "lang"]
		end
	end
end
