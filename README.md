# pCloud API

[![CI](https://github.com/jhunschejones/pcloud_api/actions/workflows/ci.yml/badge.svg)](https://github.com/jhunschejones/pcloud_api/actions/workflows/ci.yml)

The `pcloud_api` gem provides an intuitive Ruby interface for interacting with the [pCloud API](https://docs.pcloud.com/) using OAuth2. This gem does not attempt to replicate the entire functionality of the pCloud API but rather to provide quick and easy access for its most basic and common functionality. If you are looking for a lower-level pCloud API wrapper, [`pcloud`](https://github.com/7urkm3n/pcloud) might be a better fit for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pcloud_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pcloud_api

## Requirements

* Ruby 2.4.0 or higher
* `httparty`
* `tzinfo`

## Usage

### Configuration

The `Pcloud::Client` can be configured by directly calling the `Pcloud::Client.configure` method in an initializer or somewhere else in your code at startup:
```ruby
Pcloud::Client.configure(
  access_token: "your-pcloud-app-access-token",
  data_region: "EU"
)
```

You may also choose to configure the client using the `PCLOUD_API_DATA_REGION` and `PCLOUD_API_ACCESS_TOKEN` environment variables if you prefer. Advanced users can also set additional configuration values including `PCLOUD_API_TIMEOUT_SECONDS` and `PCLOUD_API_BASE_URI`.

### Available operations

There are two main objects represented in the library, `Pcloud::File` and `Pcloud::Folder`. Both attempt to present an intuitive interface that will feel quickly familiar to Ruby and Ruby on Rails developers.

The `Pcloud::File` API includes:
```ruby
# Find files by file id or path:
Pcloud::File.find(1)
Pcloud::File.find_by(path: "/images/jack_the_cat.jpg")
# NOTE: find_by can also be used with :id, though this will take precedence
# over :path so just pick one or the other

# Check if a file exists by id
Pcloud::File.exists?(1)

# Upload a new file, rename if one already exists with this name:
Pcloud::File.upload(
  folder_id: 1,
  filename: "jack_goes_swimming.mp4",
  file: File.open("/Users/joshua/Downloads/jack_goes_swimming.mp4")
)
# NOTE: the upload method will allow you to specify the :path or the :folder_id
# or you can choose to pass neither paramenter and your files will be placed
# in your root pCloud directory.

# Upload a file, force overwrite of existing file:
Pcloud::File.upload!(
  folder_id: 1,
  filename: "jack_goes_swimming.mp4",
  file: File.open("/Users/joshua/Downloads/jack_goes_swimming.mp4")
)

# Rename a file:
jack_goes_swimming.update(name: "That's one wet cat.mp4")

# Move a file by updating the parent_folder_id or path:
jack_goes_swimming.update(parent_folder_id: 9000)

# Delete a file:
jack_goes_swimming.delete

# Get a link to download a file:
jack_goes_swimming.download_link

# Access the parent folder of a file:
jack_goes_swimming.parent_folder
```

The `Pcloud::Folder` API is very similar:
```ruby
# Find folders by folder id or path:
Pcloud::Folder.find(1)
Pcloud::Folder.find_by(path: "/images")
# NOTE: find_by can also be used with :id, though this will take precedence
# over :path so just pick one or the other

# Check if a folder exists by id
Pcloud::Folder.exists?(1)

# Create a new folder by parent_folder_id and name:
Pcloud::Folder.first_or_create(parent_folder_id: 9000, name: "jack")

# Create a new folder by path:
Pcloud::Folder.first_or_create(path: "/images/jack")

# Rename a folder:
jack_images.update(name: "Jack's Photo Library")

# Move a folder by updating the parent_folder_id or path:
jack_images.update(parent_folder_id: 9000)

# Delete an empty folder:
jack_images.delete

# Recursively delete a folder and all its contents:
jack_images.delete!

# Access the parent folder of a folder:
jack_images.parent_folder

# Access the contents of a folder:
jack_images.contents
```

**Aside: path vs id**

pCloud recommends using the `folder_id`, `parent_folder_id` or `file_id` params for API calls whenever possible, rather using an exact path. Folder and file ids are static, so this will make your code less brittle to changes in the file/folder tree. You can simply look up the id for a folder in the console ahead of time and then set it in your code, similar to how you would specify an AWS S3 bucket.


**Aside: off-label client use**

The `Pcloud::File` and `Pcloud::Folder` APIs cover the most important, common functionality developers will want to access in a way that is easy to use without much onboarding. If you find that you still need to access other parts of the pCloud API that are not included in this gem yet, you can try calling other methods specified in [the pCloud API docs](https://docs.pcloud.com/) by interacting directly with the `Pcloud::Client`:
```ruby
Pcloud::Client.execute("listrevisions", query: { fileid: 90000 })
```
_(There are a few methods on the raw pCloud API that require manual login, which this gem does not yet support. If you find that you need access to these methods you may wish to look at using the [`pcloud`](https://github.com/7urkm3n/pcloud) gem instead.)_

### Generating an access token

To use the `pcloud_api` client, you will need to first generate an access token. You may do this by cloning and running the script in `./bin/generate_access_token`. It will take you through the process of setting up a pCloud app and completing the OAuth2 flow in the browser.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jhunschejones/pcloud_api.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
