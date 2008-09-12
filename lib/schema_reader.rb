#!/usr/bin/env ruby
#
#  schema_reader.rb
#  schema_reader - a quick and dirty schema stealer for rails 1.2 + (and 2.0)
#  
#  Created by James Tucker on 2008-01-09.
#  Copyright 2008 Mantissa Operations Ltd. All rights reserved.
# 

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

module SchemaReader
  module ActiveRecord
    module Schema
      def self.define(opts = {}, &blk)
        SchemaReader.schema = MiniSchema.new(opts).eval(&blk)
      end
    end
  end
  
  class <<self; attr_accessor :schema; end

  def self.load(file = 'db/schema.rb')
    Kernel.eval(File.read('db/schema.rb'), Kernel.binding)
    schema
  end
end