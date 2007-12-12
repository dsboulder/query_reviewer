module QueryReviewer
  # a single SQL SELECT query
  class SqlQuery    
    attr_reader :sql, :rows, :subqueries, :trace, :id
    
    cattr_accessor :next_id
    self.next_id = 1    
    
    def initialize(sql, rows)
      @rows = rows
      @sql = sql
      @subqueries = rows.collect{|row| SqlSubQuery.new(self, row)}
      @id = (self.class.next_id += 1)
      get_trace
    end
    
    def to_table
      rows.qa_columnized
    end
    
    def warnings
      self.subqueries.collect(&:warnings).flatten
    end
    
    def has_warnings?
      !self.warnings.empty?
    end
    
    def max_severity
      self.warnings.empty? ? 0 : self.warnings.collect(&:severity).max
    end
    
    def analyze!
      self.subqueries.collect(&:analyze!)
    end
    
    def to_hash
      @sql.hash
    end
    
    def relevant_trace
      trace.collect(&:strip).select{|t| t.starts_with?(RAILS_ROOT) && !t.starts_with?("#{RAILS_ROOT}/vendor/rails") && !t.starts_with?("#{RAILS_ROOT}/vendor/plugins/query_reviewer") }
    end
    
    def get_trace
      begin
        raise "not a real exception"
      rescue
        @trace = $!.backtrace
      end
    end
  end
end