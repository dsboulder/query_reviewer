module QueryReviewer
  module MysqlAdapterExtensions
    def self.included(base)
      base.alias_method_chain :select, :review if QueryReviewer::CONFIGURATION["enabled"]
      base.alias_method_chain :update, :review if QueryReviewer::CONFIGURATION["enabled"]
      base.alias_method_chain :insert, :review if QueryReviewer::CONFIGURATION["enabled"]
      base.alias_method_chain :delete, :review if QueryReviewer::CONFIGURATION["enabled"]
    end
    
    def update_with_review(sql, *args)
      t1 = Time.now
      result = update_without_review(sql, *args)
      t2 = Time.now

      if query_reviewer_enabled?
        query = SqlQuery.new(sql, nil, t2 - t1, nil, "UPDATE", result)
        Thread.current["queries"] << query
      end
      
      result
    end

    def insert_with_review(sql, *args)
      t1 = Time.now
      result = insert_without_review(sql, *args)
      t2 = Time.now

      if query_reviewer_enabled?
        query = SqlQuery.new(sql, nil, t2 - t1, nil, "INSERT")
        Thread.current["queries"] << query
      end

      result
    end

    def delete_with_review(sql, *args)
      t1 = Time.now
      result = delete_without_review(sql, *args)
      t2 = Time.now

      if query_reviewer_enabled?
        query = SqlQuery.new(sql, nil, t2 - t1, nil, "DELETE", result)
        Thread.current["queries"] << query
      end

      result
    end
    
    def select_with_review(sql, *args)
      sql.gsub!(/^SELECT /i, "SELECT SQL_NO_CACHE ") if QueryReviewer::CONFIGURATION["disable_sql_cache"]
      @logger.silence { execute("SET PROFILING=1") } if QueryReviewer::CONFIGURATION["profiling"]
      t1 = Time.now
      query_results = select_without_review(sql, *args)
      t2 = Time.now

      if @logger && sql =~ /^select/i && query_reviewer_enabled?
        use_profiling = QueryReviewer::CONFIGURATION["profiling"]
        use_profiling &&= (t2 - t1) >= QueryReviewer::CONFIGURATION["warn_duration_threshold"].to_f / 2.0 if QueryReviewer::CONFIGURATION["production_data"]
        
        if use_profiling
          @logger.silence { execute("SET PROFILING=1") }
          select_without_review(sql, *args)
          profile = @logger.silence { select_without_review("SHOW PROFILE ALL", *args) }
          @logger.silence { execute("SET PROFILING=0") }
        else
          profile = nil
        end

        cols = @logger.silence do
          select_without_review("explain #{sql}", *args)
        end

        query = SqlQuery.new(sql, cols, t2 - t1, profile)
        Thread.current["queries"] << query if Thread.current["queries"] && Thread.current["queries"].respond_to?(:<<)
        #@logger.debug(format_log_entry("Analyzing #{name}\n", query.to_table)) if @logger.level <= Logger::INFO
      end
      query_results
    end
    
    def query_reviewer_enabled?
      Thread.current["queries"] && Thread.current["queries"].respond_to?(:<<) && Thread.current["query_reviewer_enabled"]
    end    
  end
end