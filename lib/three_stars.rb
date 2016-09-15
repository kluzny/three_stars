# require 'byebug'
# require 'awesome_print'
require 'pg_query'
require 'three_stars/version'
require 'three_stars/helpers'
require 'three_stars/lexer'
require 'three_stars/builder'
require 'three_stars/extensions/active_record'

# Generate sql index recommendations for sql queries
module ThreeStars
  def self.new(sql, options = {})
    ThreeStars::Builder.new(sql, options).call
  end
end
