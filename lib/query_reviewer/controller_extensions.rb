require File.join(File.dirname(__FILE__), "views", "query_review_box_helper")

module QueryReviewer
  module ControllerExtensions
    class QueryViewBase < ActionView::Base
      include QueryReviewer::Views::QueryReviewBoxHelper
    end

    def self.included(base)
      if QueryReviewer::CONFIGURATION["enabled"]
        base.alias_method_chain :perform_action, :query_review if QueryReviewer::CONFIGURATION["inject_view"]
        base.alias_method_chain :process, :query_review
      end
      base.helper_method :query_review_output
    end

    def query_review_output(ajax = false)
      if QueryReviewer::CONFIGURATION["enabled"]
        faux_view = QueryViewBase.new([File.join(File.dirname(__FILE__), "views")], {}, self)
        queries = SqlQueryCollection.new(Thread.current["queries"])
        queries.analyze!
        faux_view.instance_variable_set("@queries", queries)
        if ajax
          js = faux_view.render(:partial => "/box_ajax.js")
        else
          html = faux_view.render(:partial => "/box")
        end
      else
        ""
      end
    end

    def add_query_output_to_view
      if request.xhr?
        if cookies["query_review_enabled"]
          if !response.content_type || response.content_type.include?("text/html")
            response.body += "<script type=\"text/javascript\">"+query_review_output(true)+"</script>"
          elsif response.content_type && response.content_type.include?("text/javascript")
            response.body += ";\n"+query_review_output(true)
          end
        end
      else
        if response.body.match(/<\/body>/i) && Thread.current["queries"]
          idx = (response.body =~ /<\/body>/i)
          html = query_review_output
          response.body.insert(idx, html)
        end
      end
    end

    def perform_action_with_query_review
      Thread.current["query_reviewer_enabled"] = cookies["query_review_enabled"]
      r = perform_action_without_query_review
      if QueryReviewer::CONFIGURATION["enabled"]
          (response.content_type.blank? || response.content_type.include?("text/html") || response.content_type.include?("text/javascript"))
        add_query_output_to_view
      end
      r
    end

    def process_with_query_review(request, response, method = :perform_action, *arguments) #:nodoc:
      Thread.current["queries"] = []
      process_without_query_review(request, response, method, *arguments)
    end
  end
end
