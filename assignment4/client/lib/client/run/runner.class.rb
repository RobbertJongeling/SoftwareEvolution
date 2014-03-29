module Run
	class Runner
		def run
			puts "Finding all unprocessed projects..."
			client = Travis::Client.new({
				'uri' => "https://tue.travis-ci.org/"
			})
			Project.where(:processed => false).each do |project|
				begin
					puts "Processing #{project.slug}"
				
					travis_project = client.repo(project.slug)
					project.travisid = travis_project.id
					
					contingency = Contingency.create({
						:commit_passed => 0,
						:commit_failed => 0,
						:pr_passed => 0,
						:pr_failed => 0,
						:project => project
					})
					
					travis_project.each_build do |build|
						if build.passed?
							if build.pull_request?
								contingency.commit_passed += 1
							else
								contingency.pr_passed += 1
							end
						elsif build.failed?
							if build.pull_request?
								contingency.commit_failed += 1
							else
								contingency.pr_failed += 1
							end
						end
					end
				
					
					contingency.save
					project.contingency = contingency
				rescue Travis::Client::NotFound => e
				end
				project.processed!
				project.save
			end
		end
	end
end
