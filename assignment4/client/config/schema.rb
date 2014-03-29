ActiveRecord::Schema.define do
	unless ActiveRecord::Base.connection.tables.include? 'projects'
		create_table :projects do |table|
			table.column :name, :string
			table.column :owner, :string
			table.column :processed, :boolean
			table.column :contingency_id, :integer
			table.column :travisid, :integer
			table.column :nr_contributors, :integer
			table.column :nr_changes, :integer
			table.column :age, :integer
			table.column :lang, :string
		end
	end
	
	unless ActiveRecord::Base.connection.tables.include? 'contingencies'
		create_table :contingencies do |table|
			table.column :project_id, :integer
			table.column :commit_passed, :integer
			table.column :commit_failed, :integer
			table.column :pr_passed, :integer
			table.column :pr_failed, :integer
		end
	end
end
