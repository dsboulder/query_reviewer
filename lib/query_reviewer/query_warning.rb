module QueryReviewer
  class QueryWarning
    attr_reader :query, :severity, :problem, :desc, :table, :id

    cattr_accessor :next_id
    self.next_id = 1
    
    def initialize(options)
      @query = options[:query]
      @severity = options[:severity]
      @problem = options[:problem]
      @desc = options[:desc]
      @table = options[:table]
      @id = (self.class.next_id += 1)
    end
  end
end
