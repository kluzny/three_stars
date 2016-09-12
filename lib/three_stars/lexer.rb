module ThreeStars
  # Isolates the different parts and index targets of sql statements
  class Lexer
    include ThreeStars::Helpers
    attr_accessor :sql, :parser, :tree

    def initialize(sql)
      raise "SQL can't be blank" if blank?(sql)
      self.sql = sql
      self.parser = PgQuery.parse(sql)
      self.tree = parser.tree[0]
    end

    def select_statement
      tree["SelectStmt"]
    end

    def tables
      @tables = [
        select_statement["fromClause"][0]["RangeVar"]["relname"]
      ]
    end

    def string_from_field(field)
      field[1]["str"]
    end

    def column_fields(column)
      column["ColumnRef"]["fields"]
    end

    def column_strings(column)
      column_fields(column).last.map do |field|
        string_from_field(field)
      end.compact
    end

    def select_targets
      select_statement["targetList"]
    end

    def field_from_target(target)
      column_strings(target["ResTarget"]["val"])
    end

    def selectors
      return [] if select_targets.nil?
      @selectors ||= select_targets.map do |target|
                       field_from_target(target)
                     end.flatten
    end

    def sort_clauses
      select_statement["sortClause"]
    end

    def field_of_sort_by(sort_clause)
      column_strings(sort_clause["SortBy"]["node"])
    end

    def direction_of_sort_by(sort_clause)
      sort_clause["SortBy"]["sortby_dir"] == 1 ? "ASC" : "DESC"
    end

    def field_and_direction(sort_clause)
      [ field_of_sort_by(sort_clause), direction_of_sort_by(sort_clause) ]
    end

    def orders
      return [] if sort_clauses.nil?
      @orders ||= sort_clauses.map do |sort_clause|
                    field_and_direction(sort_clause).flatten
                  end
    end

    def group_clauses
      select_statement["groupClause"]
    end

    def groups
      return [] if group_clauses.nil?
      @groups ||= group_clauses.map do |group_clause|
                    column_strings(group_clause)
                  end.flatten
    end

    def where_clauses
      select_statement["whereClause"]
    end

    def extract_expression(sub_clause)
      sub_clause["lexpr"] || sub_clause["arg"]
    end

    def extract_string_from_expression(sub_clause)
      column_strings(extract_expression(sub_clause))
    end

    def exit_type(where_type)
      where_type == "A_Expr" || where_type == "NullTest"
    end

    def denest_where_clause(where_clause)
      where_type, sub_clause = where_clause
      if where_type == "BoolExpr"
        sub_clause["args"].map do |arg|
          denest_where_clause(arg.to_a.first)
        end.flatten
      elsif !exit_type(where_type)
        denest_where_clause(sub_clause)
      else
        extract_string_from_expression(sub_clause)
      end
    end

    def wheres
      return [] if where_clauses.nil?
      @wheres ||= where_clauses.map do |where_clause|
        denest_where_clause(where_clause)
      end.flatten
    end
  end
end
