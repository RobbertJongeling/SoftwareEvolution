module Load
	class ProjectLoader
		def initialize filename
			@filename = filename
		end
		
		def import
			CSV.foreach(@filename, :headers => true) do |row|
				Project.create({
					:owner => row['owner'],
					:name => row['name'],
					:nr_contributors => row['nr_contributors'],
					:nr_changes => row['total_changes'],
					:age => row['age_in_days'],
					:lang => row['language'],
					:ghtorrentid => row['id']
				})
			end
		end
		
		def import_ghids
			CSV.foreach(@filename, :headers => true) do |row|
				project = Project.find_by_owner_and_name(row['owner'], row['name'])
				unless project.nil?
					project.ghtorrentid = row['id']
					project.save
				end
			end
		end
	end
end
