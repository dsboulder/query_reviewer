module QueryReviewer  
  module MysqlAdapterExtensions
    def self.included(base)
      base.alias_method_chain :select, :review
    end
  
    def select_with_review(sql, name = nil)
      query_results = select_without_review(sql, name)
    
      if @logger and @logger.level <= Logger::INFO and sql =~ /^select/i
        cols = @logger.silence do
          select_without_review("explain #{sql}", name)
        end
        query = SqlQuery.new(sql, cols)
        Thread.current["queries"] << query if Thread.current["queries"] && Thread.current["queries"].respond_to?(:<<)
        @logger.debug(format_log_entry("Analyzing #{name}\n", query.to_table))
      end          
      query_results
    end
  end
end