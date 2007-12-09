# Include hook code here

require "active_record"
require "action_controller"
require 'query_reviewer'
ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, QueryReviewer::MysqlAdapterExtensions)
ActionController::Base.send(:include, QueryReviewer::ControllerExtensions)
Array.send(:include, QueryReviewer::ArrayExtensions)