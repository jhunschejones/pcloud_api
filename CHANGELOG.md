## 0.2.0 2021-09-26

New
  * An `.exists?` method has been added to `Pcloud::Folder` and `Pcloud::File`
  * The `.find_by?` method on `Pcloud::Folder` and `Pcloud::File` can now be called with either `:id` or `:path`. NOTE: pCloud treats `:id` with precedence, so an error will be raised if the method is called with both parameters at once. _(Allowing precedence in a method like this would likely feel like unexpected behavior, so my intention was to make it immediately obvious to the end user.)_
  * The `.upload` method on `Pcloud::File` will now accept `created_at` and `modified_at` timestamps.

Change
 * `Pcloud::Folder` and `Pcloud::File` `created_at` and `modified_at` timestamps are now returned as Ruby `Time` objects
 * Some error class names and messages have been cleaned up for additional clarity and consistency.

## 0.1.0 2021-09-26

Initial release
