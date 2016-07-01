module ThreeStars
  # generate the recommended index
  class Builder
    attr_accessor :lexer
    def initialize(sql)
      self.lexer = Lexer.new(sql)
    end

    def call
      "add_index #{resym index_table}, #{resym index_columns}"
    end

    def resym(symbol)
      symbol.is_a?(Array) ? symbol.map(&:to_sym) : ":#{symbol}"
    end

    def index_table
      lexer.tables.first
    end

    def index_fields
      @index_fields ||= (
        lexer.orders.map(&:first) +
        lexer.groups +
        lexer.wheres +
        lexer.selectors
      ).uniq
    end

    def index_columns
      case index_fields.length
      when 0
        raise 'unable to build index, no columns lexed'
      when 1
        index_fields[0]
      else
        index_fields
      end
    end
  end
end
