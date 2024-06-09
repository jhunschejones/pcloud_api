# Cutting a new release of the pCloud API gem:
1. Update the gem version in `lib/pcloud/version.rb`.
2. Make any documentation updates.
3. Push and merge all changes.
4. Tag a new release in GitHub and summarize the changes since the last release.
5. Build the gem locally: `gem build pcloud_api.gemspec`.
    * To test the gem in a local project, you can install it with `gem install --local pcloud_api-<VERSION>.gem`
    * Make sure to update your `Gemfile` to point at the path where you built the gem, i.e. `gem "pcloud_api", path: "~/src/pcloud_api/"`
6. Publish the gem to rubygems.org: `gem push pcloud_api-<VERSION>.gem`.
