## 0.2.7 2025-08-01

**Changes**
  1. Moved the script to generate an access token inside the gem itself so that it can now be called with `Pcloud::Client.generate_access_token`
  2. Opened up the dependency requirements for HTTParty

## 0.2.6 2024-06-09

**Bugfix**
  1. Added a missing `require "time"` statement that resulted in errors for folks building and testing the gem locally. This should not affect production behavior.

## 0.2.5 2023-05-05

**Bugfix**
  1. When passing the optipnal `recursive: true` on `Pcloud::Folder#find` or `Pcloud::Folder#find_by` methods to load all the folders contents recursively in v0.2.4, recursive contents were not correctly parsed into objects. This release fixes that bug so that the recursive file tree is all `Pcloud::File` and `Pcloud::Folder` objects.

## 0.2.4 2023-05-05

**Changes**
  1. You can now specify `recursive: true` on `Pcloud::Folder#find` and `Pcloud::Folder#find_by` methods to load all the folders contents recursively. Note that this may result in long request times for folders with many items in them.
  2. You can now configure the pCloud API read and connect timeouts via a new `timeout_seconds` argument to `Pcloud::Client.configure()`. The previous way to set this value via a `PCLOUD_API_TIMEOUT_SECONDS` environment variable continues to work as before.

## 0.2.3 2021-12-14

**Changes**
  1. `Pcloud::File`'s `upload` method no longer requires a `:filename` param, since pCloud just reads it off of the file object and ignores the param anyway
  2. Both `Pcloud::File` and `Pcloud::Folder`'s `update` and `update!` methods now allow either partial paths _(starting and ending with slashes)_ or full paths. This is a little more dangerous if you specify a full path and you meant partial, but it's a reasonable use case to support.

## 0.2.2 2021-10-09

**Changes**
  1. After adding GitHub actions, I discovered that the gem did not in fact work on all the versions of Ruby that I had thought it supported. This update makes some small tweaks to bring support to Ruby 2.4 then updates the `.gemspec` to clarify that 2.3 is not in fact supported. All current users of the gem should see no behavior changes as a result of this update 👍🏻

## 0.2.1 2021-10-07

**Changes**
  1. Simplifying the errors returned from `Pcloud::Folder` and `Pcloud::File`. This is purely a cleanup release, unless your client is explicitly checking error strings there should be no noticeable behavior change 👍🏻

## 0.2.0 2021-10-07

**New**
  1. An `.exists?` method has been added to `Pcloud::Folder` and `Pcloud::File`
  2. The `.find_by` method on `Pcloud::Folder` and `Pcloud::File` can now be called with either `:id` or `:path` parameters.
     * NOTE: pCloud treats `:id` with precedence, so an error will be raised if the method is called with both parameters at once. _(Allowing precedence in a method like this would likely feel like unexpected behavior, so my intention was to make it immediately obvious to the end user.)_

**Changes**
  1. The `created_at` and `modified_at` timestamps on `Pcloud::Folder` and `Pcloud::File` are now returned as Ruby `Time` objects _(specifically [`TZInfo::TimeWithOffset`](https://www.rubydoc.info/gems/tzinfo/TZInfo/TimeWithOffset))_.
     * NOTE: if you were previously parsing the string timestamps out into time objects, you may see errors like `no implicit conversion of TZInfo::TimeWithOffset into String`
  2. Some error class names and messages have been cleaned up for additional clarity and consistency.

## 0.1.0 2021-09-26

**Initial release** 🍰 🎉
