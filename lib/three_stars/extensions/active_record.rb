module ThreeStars
  module Extensions
    module ActiveRecord
      # extend active record relations to use the ThreeStar::Builder
      module Relation
        def to_idx(options = {})
          ThreeStars.new(to_sql, options).call
        # rubocop:disable Lint/RescueException
        rescue Exception => e
          puts "Unable to lex sql: #{e.message}\n" \
            "Options: #{options} \n" \
            "SQL:\n#{to_sql}\n" \
            "Backtrace: #{e.backtrace.join("\n")}"
        end
        # rubocop:enable Lint/RescueException
      end
    end
  end
end
