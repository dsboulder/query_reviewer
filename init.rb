# Include hook code here

require 'query_reviewer'
ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, QueryReviewer::MysqlAdapterExtensions)
ActionController::Base.send(:include, QueryReviewer::ControllerExtensions)
Array.send(:include, QueryReviewer::ArrayExtensions)