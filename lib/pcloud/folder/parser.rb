module Pcloud
  class Folder
    module Parser
      def self.included(base)
        base.extend ClassMethods
        base.include ClassMethods
      end

      module ClassMethods
        def parse_one(response)
          Pcloud::Folder.new(
            id: response.dig("metadata", "folderid"),
            path: response.dig("metadata", "path"),
            name: response.dig("metadata", "name"),
            parent_folder_id: response.dig("metadata", "parentfolderid"),
            is_deleted: response.dig("metadata", "isdeleted"),
            created_at: response.dig("metadata", "created"),
            modified_at: response.dig("metadata", "modified"),
            contents: (response.dig("metadata", "contents") || []).map do |content_item|
              if content_item["isfolder"]
                Pcloud::Folder.new(
                  id: content_item["folderid"],
                  path: content_item["path"], # no path comes back from this api
                  name: content_item["name"],
                  parent_folder_id: content_item["parentfolderid"],
                  contents: recursively_parse_contents(content_item["contents"]), # this can be `nil` if recursive is false
                  is_deleted: content_item["isdeleted"],
                  created_at: content_item["created"],
                  modified_at: content_item["modified"]
                )
              else
                Pcloud::File.new(
                  id: content_item["fileid"],
                  path: content_item["path"],
                  name: content_item["name"],
                  content_type: content_item["contenttype"],
                  category_id: content_item["category"],
                  size: content_item["size"],
                  parent_folder_id: content_item["parentfolderid"],
                  is_deleted: content_item["isdeleted"],
                  created_at: content_item["created"],
                  modified_at: content_item["modified"]
                )
              end
            end
          )
        end

        private

        def recursively_parse_contents(contents)
          return nil if contents.nil?
          contents.map do |content_item|
            if content_item["isfolder"]
              Pcloud::Folder.new(
                id: content_item["folderid"],
                path: content_item["path"], # no path comes back from this api
                name: content_item["name"],
                parent_folder_id: content_item["parentfolderid"],
                contents: recursively_parse_contents(content_item["contents"]),
                is_deleted: content_item["isdeleted"],
                created_at: content_item["created"],
                modified_at: content_item["modified"]
              )
            else
              Pcloud::File.new(
                id: content_item["fileid"],
                path: content_item["path"],
                name: content_item["name"],
                content_type: content_item["contenttype"],
                category_id: content_item["category"],
                size: content_item["size"],
                parent_folder_id: content_item["parentfolderid"],
                is_deleted: content_item["isdeleted"],
                created_at: content_item["created"],
                modified_at: content_item["modified"]
              )
            end
          end
        end
      end
    end
  end
end
