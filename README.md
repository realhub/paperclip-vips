# paperclip-vips

A custom paperclip processor that uses the [libvips image processing library](https://libvips.github.io/libvips) for faster image resizing and manipulation.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'paperclip-vips'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install paperclip-vips

Note: You will need to have libvips installed on your machine for this processor to work correctly.

## Usage

Basic Example:

```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar,
    styles: {
        medium: { geometry: '300x300' },
        thumb: { geometry: '100x100#' }
    },
    processors: [:vips]
end
```

You can also provide additional processing steps by passing a json array to paperclip convert_options:

```ruby
class User < ActiveRecord::Base
  has_attached_file :avatar,
    styles: {
        medium: { geometry: '300x300' },
        thumb: { geometry: '100x100#' }
    },
    :convert_options => {
        :cmyk_original => lambda { |file| [{
            cmd: "icc_transform",
            args: ["PATH_TO_PROFILE"],
            optional: {
                input_profile: "PATH_TO_INPUT_PROFILE",
                intent: :perceptual,
            },
        }].to_json }
    },
    processors: [:vips]
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/paperclip-vips. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Paperclip::Vips project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/paperclip-vips/blob/master/CODE_OF_CONDUCT.md).
