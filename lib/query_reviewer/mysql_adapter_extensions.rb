module QueryReviewer
  module MysqlAdapterExtensions
    def self.included(base)
      base.alias_method_chain :select, :review if QueryReviewer::CONFIGURATION["enabled"]
    end

    def select_with_review(sql, name = nil)
      @logger.silence { execute("SET PROFILING=1") } if QueryReviewer::CONFIGURATION["profiling"]
      t1 = Time.now
      query_results = select_without_review(sql, name)
      t2 = Time.now

      if @logger and sql =~ /^select/i
        use_profiling = QueryReviewer::CONFIGURATION["profiling"]
        use_profiling &&= (t2 - t1) >= QueryReviewer::CONFIGURATION["warn_duration_threshold"].to_f / 2.0 if QueryReviewer::CONFIGURATION["production_data"]
        
        if use_profiling
          @logger.silence { execute("SET PROFILING=1") }
          select_without_review(sql, name)
          profile = @logger.silence { select_without_review("SHOW PROFILE ALL", name) }
          @logger.silence { execute("SET PROFILING=0") }
        else
          profile = nil
        end

        cols = @logger.silence do
          select_without_review("explain #{sql}", name)
        end

        query = SqlQuery.new(sql, cols, t2 - t1, profile)
        Thread.current["queries"] << query if Thread.current["queries"] && Thread.current["queries"].respond_to?(:<<)
        @logger.debug(format_log_entry("Analyzing #{name}\n", query.to_table)) if @logger.level <= Logger::INFO
      end
      query_results
    end
  end
end