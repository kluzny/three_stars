
module ThreeStars
  # generate the recommended index
  class Builder
    include ThreeStars::Helpers
    attr_accessor :lexer, :name

    MAX_INDEX_NAME_LENGTH = 48 # good enough for mysql/psql

    def initialize(sql, options = {})
      self.name = options[:name]
      self.lexer = Lexer.new(sql)
    end

    def call
      "add_index #{resym index_table}, " \
        "#{resym index_columns}#{index_name_builder}".strip
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

    def index_name_builder
      present?(index_name) ? ", name: '#{index_name}'" : ""
    end

    def index_name
      @index_name ||= if present?(name)
                        name
                      elsif index_name_too_long?
                        slice_first_index_chars
                      end
    end

    def index_name_too_long?
      index_fields.join("_").length > MAX_INDEX_NAME_LENGTH - 4
    end

    def slice_first_index_chars
      slice_width = 3
      field_count = (MAX_INDEX_NAME_LENGTH / (slice_width + 1)) - 1
      index_fields.slice(0, field_count).map do |column|
        column.slice(0, slice_width)
      end.join("_") + "_idx"
    end
  end
end
