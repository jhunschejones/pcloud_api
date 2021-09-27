# Cutting a new release of the pCloud API gem:
1. Update the gem version in `lib/pcloud/version.rb`.
2. Make any documentation updates.
3. Tag a new release in GitHub and summarize the changes since the last release.
4. Build the gem locally: `gem build pcloud_api.gemspec`.
 * To test the gem in a local project, you can install it with `gem install --local pcloud_api-<VERSION>.gem`
5. Publish the gem to rubygems.org: `gem push pcloud_api-<VERSION>.gem`.
