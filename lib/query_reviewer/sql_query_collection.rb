module QueryReviewer
  # a collection of SQL SELECT queries  
  class SqlQueryCollection
    attr_reader :queries
    def initialize(queries)
      @queries = queries
    end
    
    def analyze!
      self.queries.collect(&:analyze!)

      @warnings = []
      
      if @queries.length > QueryReviewer::CONFIGURATION["critical_query_count"]
        warn(:severity => ((QueryReviewer::CONFIGURATION["critical_severity"] + 10)/2).to_i, :problem => "#{@queries.length} queries on this page", :description => "Too many queries can severely slow down a page")
      elsif @queries.length > QueryReviewer::CONFIGURATION["warn_query_count"]
        warn(:severity => ((QueryReviewer::CONFIGURATION["warn_severity"] + QueryReviewer::CONFIGURATION["critical_severity"])/2).to_i, :problem => "#{@queries.length} queries on this page", :description => "Too many queries can slow down a page")
      end
    end
    
    def warn(options)
      @warnings << QueryWarning.new(options)
    end
    
    def warnings
      self.queries.collect(&:warnings).flatten.sort{|a,b| a.severity <=> b.severity}.reverse
    end
    
    def collection_warnings
      @warnings
    end
    
    def max_severity
      warnings.empty? && collection_warnings.empty? ? 0 : [warnings.empty? ? 0 : warnings.collect(&:severity).flatten.max, collection_warnings.empty? ? 0 : collection_warnings.collect(&:severity).flatten.max].max
    end
    
    def total_severity
      warnings.collect(&:severity).sum
    end
    
    def total_with_warnings
      queries.select(&:has_warnings?).length
    end

    def total_without_warnings
      queries.length - total_with_warnings
    end
    
    def percent_with_warnings
      queries.empty? ? 0 : (100.0 * total_with_warnings / queries.length).to_i
    end

    def percent_without_warnings
      queries.empty? ? 0 : (100.0 * total_without_warnings / queries.length).to_i
    end
  end
end