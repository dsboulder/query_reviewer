require File.join(File.dirname(__FILE__), "views", "query_review_box_helper")

module QueryReviewer
  module ControllerExtensions
    class QueryViewBase < ActionView::Base
      include QueryReviewer::Views::QueryReviewBoxHelper
    end
    
    def self.included(base)
      base.alias_method_chain :perform_action, :query_review
      base.alias_method_chain :process, :query_review
    end
    
    def add_query_output_to_view
      if response.body.match(/<\/body>/i) && Thread.current["queries"]
        idx = (response.body =~ /<\/body>/i)
        faux_view = QueryViewBase.new([File.join(File.dirname(__FILE__), "views")], {}, self)
        queries = SqlQueryCollection.new(Thread.current["queries"])
        queries.analyze!
        faux_view.instance_variable_set("@queries", queries)
        html = faux_view.render(:partial => "/box.rhtml")
        response.body.insert(idx, html)
      end
    end
    
    def perform_action_with_query_review
      r = perform_action_without_query_review
      add_query_output_to_view if response.content_type.blank? || response.content_type == "text/html"
      r
    end
    
    def process_with_query_review(request, response, method = :perform_action, *arguments) #:nodoc:
      Thread.current["queries"] = []
      process_without_query_review(request, response, method, *arguments)
    end
  end
end
