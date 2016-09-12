module ThreeStars
  module Extensions
    module ActiveRecord
      module Relation
        def to_idx
          ThreeStars::Builder.new(to_sql).call
        rescue Exception => e
          puts "Unable to lex sql: #{e.message}\n""SQL:\n#{to_sql}\nBacktrace: #{e.backtrace.join("\n")}"
        end
      end
    end
  end
end
