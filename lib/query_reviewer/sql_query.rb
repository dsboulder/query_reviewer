require "ostruct"

module QueryReviewer
  # a single SQL SELECT query
  class SqlQuery
    attr_reader :sql, :rows, :subqueries, :trace, :id, :profile, :duration, :command, :affected_rows

    cattr_accessor :next_id
    self.next_id = 1

    def initialize(sql, rows, duration = 0.0, profile = nil, command = "SELECT", affected_rows = 1)
      @rows = rows
      @sql = sql
      @subqueries = rows ? rows.collect{|row| SqlSubQuery.new(self, row)} : []
      @id = (self.class.next_id += 1)
      @profile = profile.collect { |p| OpenStruct.new(p) } if profile
      @duration = duration.to_f
      @warnings = []
      @command = command
      @affected_rows = affected_rows
      get_trace
    end

    def to_table
      rows.qa_columnized
    end

    def warnings
      self.subqueries.collect(&:warnings).flatten + @warnings
    end

    def has_warnings?
      !self.warnings.empty?
    end

    def max_severity
      self.warnings.empty? ? 0 : self.warnings.collect(&:severity).max
    end

    def table
      @subqueries.first.table
    end

    def analyze!
      self.subqueries.collect(&:analyze!)
      if duration
        if duration >= QueryReviewer::CONFIGURATION["critical_duration_threshold"]
          warn(:problem => "Query took #{duration} seconds", :severity => 9)
        elsif duration >= QueryReviewer::CONFIGURATION["warn_duration_threshold"]
          warn(:problem => "Query took #{duration} seconds", :severity => QueryReviewer::CONFIGURATION["critical_severity"])
        end
      end
      
      if affected_rows >= QueryReviewer::CONFIGURATION["critical_affected_rows"]
        warn(:problem => "#{affected_rows} rows affected", :severity => 9, :description => "An UPDATE or DELETE query can be slow and lock tables if it affects many rows.")
      elsif affected_rows >= QueryReviewer::CONFIGURATION["warn_affected_rows"]
        warn(:problem => "#{affected_rows} rows affected", :severity => QueryReviewer::CONFIGURATION["critical_severity"], :description => "An UPDATE or DELETE query can be slow and lock tables if it affects many rows.")
      end
    end

    def to_hash
      @sql.hash
    end

    def relevant_trace
      trace.collect(&:strip).select{|t| t.starts_with?(RAILS_ROOT) &&
          (!t.starts_with?("#{RAILS_ROOT}/vendor") || QueryReviewer::CONFIGURATION["trace_includes_vendor"]) &&
          (!t.starts_with?("#{RAILS_ROOT}/lib") || QueryReviewer::CONFIGURATION["trace_includes_lib"]) &&
          !t.starts_with?("#{RAILS_ROOT}/vendor/plugins/query_reviewer") }
    end

    def full_trace
      trace.collect(&:strip).select{|t| !t.starts_with?("#{RAILS_ROOT}/vendor/plugins/query_reviewer") }
    end

    def get_trace
      @trace = Kernel.caller
    end
    
    def warn(options)
      options[:query] = self
      options[:table] ||= self.table
      @warnings << QueryWarning.new(options)
    end

    def select?
      self.command == "SELECT"
    end
  end
end