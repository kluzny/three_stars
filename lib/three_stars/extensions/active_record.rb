module ThreeStars
  module Extensions
    module ActiveRecord
      # extend active record relations to use the ThreeStar::Builder
      module Relation
        def to_idx
          ThreeStars::Builder.new(to_sql).call
        # rubocop:disable Lint/RescueException
        rescue Exception => e
          puts "Unable to lex sql: #{e.message}\n""SQL:\n#{to_sql}\nBacktrace: #{e.backtrace.join("\n")}"
        end
        # rubocop:enable Lint/RescueException
      end
    end
  end
end
