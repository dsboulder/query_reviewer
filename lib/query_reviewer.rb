# QueryReviewer
require "ostruct"

module QueryReviewer
  CONFIGURATION = {}
    
  def self.load_configuration
    CONFIGURATION.merge!(YAML.load(File.read(File.join(File.dirname(__FILE__), "..", "query_reviewer_defaults.yml")))["all"] || {})
    CONFIGURATION.merge!(YAML.load(File.read(File.join(File.dirname(__FILE__), "..", "query_reviewer_defaults.yml")))[RAILS_ENV || "test"] || {})
    
    app_config_file = File.join(RAILS_ROOT, "config", "query_reviewer.yml")
        
    if File.exist?(app_config_file)
      CONFIGURATION.merge!(YAML.load(File.read(app_config_file))["all"] || {}) 
      CONFIGURATION.merge!(YAML.load(File.read(app_config_file))[RAILS_ENV || "test"] || {}) 
    end
    
    if enabled?
      begin      
        CONFIGURATION["uv"] ||= !Gem.searcher.find("uv").nil?
        if CONFIGURATION["uv"]
          require "uv"
        end
      rescue
        CONFIGURATION["uv"] ||= false    
      end
    end    
  end
  
  def self.enabled?
    CONFIGURATION["enabled"]
  end
end

QueryReviewer.load_configuration

if QueryReviewer.enabled?
  require "query_reviewer/query_warning"
  require "query_reviewer/array_extensions"
  require "query_reviewer/sql_query"
  require "query_reviewer/mysql_analyzer"
  require "query_reviewer/sql_sub_query"
  require "query_reviewer/mysql_adapter_extensions"
  require "query_reviewer/controller_extensions"
  require "query_reviewer/sql_query_collection"
end
