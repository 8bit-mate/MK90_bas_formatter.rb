# MK90BasFormatter

Formats output from the [MK90_bas_img_generator](https://github.com/8bit-mate/MK90_bas_img_generator.rb) gem to a valid executable Elektronika MK90 BASIC code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'MK90_bas_formatter'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install MK90_bas_formatter

## Usage
```ruby
require "MK90_bas_img_generator"
require "MK90_bas_formatter"

# Generate list of BASIC statements:
bas_generator = MK90BasImgGenerator.new(
  generator: generator.new,
  binary_image: bin_img
)

statements_arr = bas_generator.generate

# Choose formatter type:
formatter = Minificator

# Format statements_arr into an executable BASIC script:
exec_script = MK90BasFormatter.new(statements_arr, formatter.new).format

# Save exec_script to a file, etc...
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/8bit-mate/MK90_bas_formatter.rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
