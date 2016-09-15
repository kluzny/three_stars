module ThreeStars
  # generate the recommended index
  class Builder
    include ThreeStars::Helpers
    attr_accessor :lexer, :name

    MAX_INDEX_NAME_LENGTH = 48 # good enough for mysql/psql
    INDEX_NAME_SUFFIX = -'idx'

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
      present?(index_name) ? ", name: '#{index_name}'" : ''
    end

    def index_name
      @index_name ||= if present?(name)
                        name
                      elsif index_name_too_long?
                        generate_index_name
                      end
    end

    # http://apidock.com/rails/ActiveRecord/ConnectionAdapters/SchemaStatements/add_index
    def rails_style_index_name
      index_fields
        .dup
        .unshift(index_table)
        .push(INDEX_NAME_SUFFIX)
        .join('_')
    end

    def index_name_too_long?
      rails_style_index_name.length > MAX_INDEX_NAME_LENGTH
    end

    def generate_index_name
      truncate_after = 3
      delimiter = '_'
      next_slice = truncate_after + delimiter.length
      max_length = MAX_INDEX_NAME_LENGTH - INDEX_NAME_SUFFIX.length - next_slice
      generated = index_table
      index_fields.each do |field|
        break if generated.length >= max_length
        generated << delimiter + field.slice(0, truncate_after)
      end
      generated + delimiter + INDEX_NAME_SUFFIX
    end
  end
end
