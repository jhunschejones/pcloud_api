module Pcloud
  class File
    module Parser
      def self.included(base)
        base.extend ClassMethods
        base.include ClassMethods
      end

      module ClassMethods
        def parse_one(response)
          Pcloud::File.new(
            id: response.dig("metadata", "fileid"),
            path: response.dig("metadata", "path"),
            name: response.dig("metadata", "name"),
            content_type: response.dig("metadata", "contenttype"),
            category_id: response.dig("metadata", "category"),
            size: response.dig("metadata", "size"),
            parent_folder_id: response.dig("metadata", "parentfolderid"),
            is_deleted: response.dig("metadata", "isdeleted"),
            created_at: response.dig("metadata", "created"),
            modified_at: response.dig("metadata", "modified")
          )
        end

        def parse_many(response)
          response["metadata"].map do |metadata|
            Pcloud::File.new(
              id: metadata["fileid"],
              path: metadata["path"],
              name: metadata["name"],
              content_type: metadata["contenttype"],
              category_id: metadata["category"],
              size: metadata["size"],
              parent_folder_id: metadata["parentfolderid"],
              is_deleted: metadata["isdeleted"],
              created_at: metadata["created"],
              modified_at: metadata["modified"]
            )
          end
        end
      end
    end
  end
end
