# IiifGoogleCv

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/iiif_google_cv`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iiif_google_cv'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iiif_google_cv

## Usage

Activate and authorize an interactive session using [Google Cloud Vision Authentication](http://googlecloudplatform.github.io/google-cloud-ruby/#/docs/google-cloud-vision/v0.27.0/guides/authentication#withgooglecloudruby) and project id

```sh
$ VISION_PROJECT="my-project-id" VISION_KEYFILE=Project\ Key\ File.json bin/console
```

Create a new `IiifGoogleCv::Client`

```ruby
> c = IiifGoogleCv::Client.new(manifest_url: 'https://purl.stanford.edu/hg676jb4964/iiif/manifest')
```

Create a manifest with annotations from the client

```ruby
> c.iiif_manifest_with_annotations
Annotating ["https://stacks.stanford.edu/image/iiif/hg676jb4964%2F0380_796-44/full/pct:50/0/default.jpg"]
=> "https://api.myjson.com/bins/12uue9"
```

The returned url is now an annotated manifest of the images and can be viewed in a IIIF viewer like [Mirador](http://projectmirador.org/demo/).

The API calls will fail if the images are too big or do not respond in time. You can modify the responding images from the IIIF Image API by changing the `SCALE_FACTOR` environment variable. This defaults to `0.5` (50% of original size).


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mejackreed/iiif_google_cv.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
