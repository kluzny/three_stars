module ThreeStars
  # Isolates the different parts and index targets of sql statements
  class Lexer
    attr_accessor :sql, :parser, :ast

    def initialize(sql)
      raise "SQL can't be blank" if blank?(sql)
      self.sql = sql
      self.parser = SQLParser::Parser.new
      self.ast = parser.scan_str(sql)
    end

    def blank?(string)
      string.nil? || !string.is_a?(String) || string.strip.empty?
    end

    def tables
      @tables ||= ast
                  .query_expression
                  .table_expression
                  .from_clause
                  .tables
                  .map(&:name)
    rescue
      @tables = []
    end

    def selectors
      @selectors ||= ast
                     .query_expression
                     .list
                     .columns
                     .map(&:name)
    rescue
      @selectors = []
    end

    def orders
      @orders ||= ast.order_by.sort_specification.map do |clauses|
        field, direction = clauses.to_sql.split
        [field.tr('`', ''), direction.downcase]
      end
    rescue
      @orders = []
    end

    def groups
      @groups ||= ast
                  .query_expression
                  .table_expression
                  .group_by_clause
                  .columns
                  .map(&:name)
    rescue
      @groups = []
    end

    def wheres
      @wheres ||= [ast
        .query_expression
        .table_expression
        .where_clause
        .search_condition
        .left
        .name
      ]
    rescue
      @wheres = []
    end
  end
end
