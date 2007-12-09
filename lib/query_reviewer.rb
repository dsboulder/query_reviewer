# QueryReviewer
require "ostruct"
require "query_reviewer/array_extensions"
require "query_reviewer/sql_query"
require "query_reviewer/sql_sub_query"
require "query_reviewer/mysql_adapter_extensions"
require "query_reviewer/controller_extensions"


module QueryReviewer
  CONFIGURATION = YAML.load(File.read(File.join(File.dirname(__FILE__), "..", "query_reviewer.yml")))["all"] || {}
  CONFIGURATION.merge!(YAML.load(File.read(File.join(File.dirname(__FILE__), "..", "query_reviewer.yml")))[RAILS_ENV || "development"])
  
  if CONFIGURATION["enabled"]
    begin      
      CONFIGURATION["uv"] ||= !Gem.searcher.find("uv").nil?
      if CONFIGURATION["uv"]
        require "uv"
      end
    rescue
      CONFIGURATION["uv"] ||= false    
    end
  end
  
  class QueryWarning
    attr_reader :query, :severity, :problem, :desc, :table, :id

    cattr_accessor :next_id
    self.next_id = 1
    
    def initialize(options)
      @query = options[:query]
      @severity = options[:severity]
      @problem = options[:problem]
      @desc = options[:desc]
      @table = options[:table]
      @id = (self.class.next_id += 1)
    end
  end
end