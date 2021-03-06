[![Build Status](https://travis-ci.org/kluzny/three_stars.svg?branch=master)](https://travis-ci.org/kluzny/three_stars)
# ThreeStars

ThreeStars is an attempt to analyze basic sql queries and provide database index recommendations. Unfortunatley, this can't solve all of your sql performance problems, but hopefully, it can make the task trivial in simple cases.

This is not particularly useful for exceptionally large unruly queries e.g. joins, wildcard full text searches, and range based selectors. Queries with clear where targets and congurent group_by and order clauses should see a subtantial improvement, even on high row counts. Not every query analyzed will see an improvement. It is said that database indexes are more of an art than a science, and you should consult your local wizard, DBA, benchmarks, intuition, and RDBMS documentation before you attempt this in production.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'three_stars', group: :development
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install three_stars

If you are using rails and want to bolt this directly onto ActiveRecord, create the file `config/initializers/three_stars.rb` with the following:

```ruby
if Rails.env.development?
  ActiveRecord::Relation.include ThreeStars::Extensions::ActiveRecord::Relation
end
```

This adds the method `to_idx` similar to `to_sql`

## Usage

1. Write/find a nasty slow query you'd like to improve
2. Consider performing a pre-index benchmark, or at least note the query time in your development log
3. Throw in a debugger BEFORE your query ( to mitigate sql caching )
4. Append `.to_idx` to the query and execute it
5. Review the sql, explanation, and the recommended index
6. Create a migration file for the index ( or just execute it )
7. Grab some coffee or tea while the index builds
8. Pontificate on hiring a DBA ( those indexes don't always build quickly )
9. Review the query performance and rebenchmark. ( on the bright side it's much quiker to drop an index )

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kluzny/three_stars.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Acknowledgements

The inspiration for this gem came from a slide presentation [How to Design Indexes, Really](http://www.slideshare.net/billkarwin/how-to-design-indexes-really) by Bill Karwin. It's a good read if you need an overview of db indexes. It hints at the namesake's origin as well in [Relational Database Index Design and the Optimizers] (http://www.wiley.com/WileyCDA/WileyTitle/productCd-0471719994.html) which admitedly I haven't read.
