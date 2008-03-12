
def log *args
  args.each do |msg|
    puts msg
  end
end

class MiniSchema
  class MiniTable
    attr_accessor :name, :options, :columns, :indexes
    
    def initialize name, options = {}
      @name = name
      @options = options
      @columns = {}
      @indexes = {}
    end
    
    # rails 2 / sexy migrations
    def method_missing(name, *args)
      @columns[args[0]] = [name, args[1]]
    end
    
    def column name, type, options = {}
      @columns[name] = [type, options]
    end
    
    def eval &blk
      self.instance_eval &blk
      self
    end
    
    def add_index col, name
      @indexes[col] = name
    end
  end
  
  attr_accessor :tables, :options
  
  def initialize options = {}
    @options = options
    @tables = {}
  end
  
  def create_table name, options = {}, &blk
    @tables[name] = MiniTable.new(name, options).eval(&blk)
  end
  
  def add_index table, column, name
    @tables[table].add_index column, name
  end
  
  def eval &blk
    self.instance_eval &blk
    self
  end
  
end

module ActiveRecord
  module Schema
    class <<self
      attr_accessor :schema
    end
    
    def self.define(opts = {}, &blk)
      log "Version: #{opts[:version]}" if opts[:version]
      require 'pp'
      @schema = MiniSchema.new(opts).eval(&blk)
    end
    
    def self.table_to_scaffold_args tablename
      @schema.tables[tablename].columns.map{|k, v| k + ':' + v[0].to_s}.join(' ')
    end

  end
end


require 'schema.rb'

