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
