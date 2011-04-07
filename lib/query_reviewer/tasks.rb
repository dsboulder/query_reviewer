namespace :query_reviewer do
  desc "Create a default config/query_reviewer.yml"
  task :setup do
    defaults_path = File.join(File.dirname(__FILE__), "../..", "query_reviewer_defaults.yml")
    dest_path = File.join(Rails.root.to_s, "config", "query_reviewer.yml")
    FileUtils.copy(defaults_path, dest_path)
  end
end