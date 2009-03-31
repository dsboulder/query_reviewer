# QueryReviewer
require "ostruct"
require 'erb'
require 'yaml'

module QueryReviewer
  CONFIGURATION = {}
    
  def self.load_configuration
    default_config = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), "..", "query_reviewer_defaults.yml"))).result)
    
    CONFIGURATION.merge!(default_config["all"] || {})
    CONFIGURATION.merge!(default_config[RAILS_ENV || "test"] || {})
    
    app_config_file = File.join(RAILS_ROOT, "config", "query_reviewer.yml")
        
    if File.exist?(app_config_file)
      app_config = YAML.load(ERB.new(IO.read(app_config_file)).result)
      CONFIGURATION.merge!(app_config["all"] || {}) 
      CONFIGURATION.merge!(app_config[RAILS_ENV || "test"] || {}) 
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
