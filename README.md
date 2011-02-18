# QueryReviewer #

## Introduction ##

QueryReviewer is an advanced SQL query analyzer.  It accomplishes the following goals:

 * View all EXPLAIN output for all SELECT queries to generate a page
 * Rate a page's SQL usage into one of three categories: OK, WARNING, CRITICAL
 * Attach meaningful warnings to individual queries, and collections of queries
 * Display interactive summary on page

## Fork ##

I use this for all my rails projects. Still the best out there in my opinion for analyzing and understanding your ActiveRecord generated queries. I forked the original [query_reviewer](https://github.com/dsboulder/query_reviewer) and applied a collection of patches that have been made since the plugin was originally created. A list of additions is below:

 * Snazzed up the README into markdown for better readability
 * Fix deprecated use of `require 'activesupport` to `active_support`
 * Cleanup and move rake task to `lib/tasks` to fix deprecation warnings
 * Added gemspec for use with Bundler
 * Fixed missing tags and additional XHTML escaping
 * Fix sql escaping for XHTML compatibility
 * Fixes for deprecation warnings and for 1.9 compatiblity
 * Converts templates to Rails 2 + 3 friends .html.erb naming

Last commit to main repository was on March 30th, 2009. Compiled a variety of fixes that were made since that time.

## Installation ##

All you have to do is install it! Right now this is a fork so assuming you use bundler:

    # Gemfile
    gem "query_reviewer", :git => "git://github.com/nesquena/query_reviewer.git"

You can then run:

    rake query_reviewer:setup

Which will create `config/query_reviewer.yml`, see below for what these options mean.
If you don't create a config file, the gem will use the default in `vendor/plugins/query_reviewer`.


## Configuration ##

The configuration file allows you to set configuration parameters shared across all rails environment, as well as overriding those shared parameteres with environment-specific parameters (such as disabling analysis on production!)

 * `enabled`: whether any output or query analysis is performed.  Set this false in production!
 * `inject_view`: controls whether the output automatically is injected before the &lt;/body&gt; in HTML output.
 * `profiling`: when enabled, runs the MySQL SET PROFILING=1 for queries longer than the `warn_duration_threshold` / 2.0
 * `production_data`: whether the duration of a query should be taken into account (if you don't have real data, don't let query duration effect you!)

 * `stack_trace_lines`: number of lines of call stack to include in the "short" version of the stack trace
 * `trace_includes_vendor`: whether the "short" verison of the stack trace should include files in /vendor
 * `trace_includes_lib`: whether the "short" verison of the stack trace should include files in /lib

 * `warn_severity`: the severity of problem that merits "WARNING" status
 * `critical_severity`: the severity of problem that merits "CRITICAL" status

 * `warn_query_count`: the number of queries in a single request that merits "WARNING" status
 * `critical_query_count`: the number of queries in a single request that merits "CRITICAL" status

 * `warn_duration_threshold`: how long a query must take in seconds (float) before it's considered "WARNING"
 * `critical_duration_threshold`: how long a query must take in seconds (float) before it's considered "CRITICIAL"

## Example ##

If you disable the inject_view option, you'll need to manually put the analyzer's output into your view:

    # view.html.haml
    = query_review_output

and that will display the analyzer view!

## Resources ##

Random collection of resources that might be interesting related to this utility:

 * <http://blog.purifyapp.com/2010/06/15/optimise-your-mysql/>
 * <http://www.tatvartha.com/2009/09/rails-optimizing-database-indexes-using-query_analyzer-and-query_reviewer/>
 * <http://www.geekskillz.com/articles/using-indexes-to-improve-rails-performance>
 * <http://www.williambharding.com/blog/rails/rails-mysql-indexes-step-1-in-pitiful-to-prime-performance/>
 * <http://guides.rubyonrails.org/performance_testing.html>

## Alternatives ##

There have been other alternatives created since this was originally released. A few of the best are listed below. I for one still prefer this utility over the other options:

 * [rack-bug](https://github.com/brynary/rack-bug)
 * [rails-footnotes](https://github.com/josevalim/rails-footnotes)
 * [newrelic-development](http://support.newrelic.com/kb/docs/developer-mode)
 * [palmist](https://github.com/flyingmachine/palmist)

## Acknowledgements ##

Created by Kongregate & David Stevenson. Refactorings and compilations of all fixes since was done by Nathan Esquenazi.

Copyright (c) 2007-2008 Kongregate & David Stevenson, released under the MIT license