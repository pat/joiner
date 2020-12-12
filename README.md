# Joiner

This gem, abstracted out from [Thinking Sphinx](http://pat.github.io/thinking-sphinx), turns a bunch of association trees from the perspective of a single model and builds a bunch of OUTER JOINs that can be passed into ActiveRecord::Relation's `join` method. You can also find out the generated table aliases for each join, in case you're referring to columns from those joins at some other point.

If this gem is used by anyone other than myself/Thinking Sphinx, I'll be surprised. My reason for pulling it out is so I can more cleanly support Rails' changing approaches to join generation (see v3.1-v4.0 compared to v4.1-v5.1 compared to v5.2).

## Installation

It's a gem - so you can either install it yourself, or add it to the appropriate Gemfile or gemspec.

```term
gem install joiner --version 0.6.0
```

## Usage

First, create a join collection, based on an ActiveRecord model:

```ruby
joiner = Joiner::Joins.new User
```

Then you can add joins for a given association path. For example, if User has many articles, and articles have many comments:

```ruby
joiner.add_join_to [:articles]
joiner.add_join_to [:articles, :comments]
```

If you need the table/join alias for a given association path, just ask for it:

```ruby
joiner.alias_for([:articles, :comments])
```

And once you've loaded up all the joins, you'll want something you can push out into `ActiveRecord::Relation#joins`:

```ruby
User.joins(joiner.join_values)
```

You can also check if a given association path will return potentially more than one record (thus perhaps requiring aggregation), or find out what the model at the end of the path is:

```ruby
path = Joiner::Path.new(User, [:articles, :comments])
path.aggregate? #=> true
path.model      #=> Comment
```

## Contributing

Please note that this project now has a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/0/0/). By participating in this project you agree to abide by its terms.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Licence

Copyright (c) 2013-2020, Joiner is developed and maintained by [Pat Allan](http://freelancing-gods.com), and is released under the open MIT Licence.
