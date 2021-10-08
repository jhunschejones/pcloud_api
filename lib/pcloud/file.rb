module Pcloud
  class File
    class InvalidParameter < StandardError; end
    class InvalidParameters < StandardError; end
    class MissingParameter < StandardError; end
    class UploadFailed < StandardError; end

    include Parser
    include Pcloud::TimeHelper

    SUPPORTED_UPDATE_PARAMS = [:name, :parent_folder_id, :path].freeze
    SUPPORTED_FIND_BY_PARAMS = [:id, :path].freeze
    FILE_CATAGORIES = {
      "0" => "uncategorized",
      "1" => "image",
      "2" => "video",
      "3" => "audio",
      "4" => "document",
      "5" => "archive",
    }.freeze

    attr_reader :id, :path, :name, :content_type, :category, :size,
                :parent_folder_id, :is_deleted, :created_at, :modified_at

    def initialize(params)
      @id = params.fetch(:id)
      @path = params.fetch(:path)
      @name = params.fetch(:name)
      @content_type = params.fetch(:content_type)
      @category = FILE_CATAGORIES.fetch((params.fetch(:category_id) || 0).to_s)
      @size = params.fetch(:size) # bytes
      @parent_folder_id = params.fetch(:parent_folder_id)
      @is_deleted = params.fetch(:is_deleted) || false
      @created_at = time_from(params.fetch(:created_at))
      @modified_at = time_from(params.fetch(:modified_at))
    end

    def update(params)
      unless (params.keys - SUPPORTED_UPDATE_PARAMS).empty?
        raise InvalidParameters.new("Must be one of #{SUPPORTED_UPDATE_PARAMS}")
      end
      if params[:path] && is_invalid_path_update_param?(params[:path])
        raise InvalidParameter.new(":path param must start and end with `/`")
      end
      query = {
        fileid: id,
        tofolderid: params[:parent_folder_id] || nil,
        toname: params[:name] || nil,
        topath: params[:path] || nil
      }.compact
      parse_one(Client.execute("renamefile", query: query))
    end

    def delete
      parse_one(Client.execute("deletefile", query: { fileid: id }))
    end

    def parent_folder
      @parent_folder ||= Pcloud::Folder.find(parent_folder_id)
    end

    def download_url
      @download_url ||= begin
        file_url_parts = Client.execute(
          "getfilelink",
          query: { fileid: id, forcedownload: 1, skipfilename: 1 }
        )
        "https://#{file_url_parts["hosts"].first}#{file_url_parts["path"]}"
      end
      # This allows us to cache the expensive part of this method, requesting
      # a download URL from pcloud, while maintaining consistency if the file
      # name changes later.
      "#{@download_url}/#{URI.encode_www_form_component(name)}"
    end

    private

    def is_invalid_path_update_param?(path_param)
      # Path params have to start and end with `/` when used with .update
      [path_param[0], path_param[-1]] != ["/", "/"]
    end

    class << self
      def exists?(id)
        find(id)
        true
      rescue Pcloud::Client::ErrorResponse => e
        return false if e.message == "File not found."
        raise e
      end

      def find(id)
        parse_one(Client.execute("stat", query: { fileid: id }))
      end

      def find_by(params)
        unless (params.keys - SUPPORTED_FIND_BY_PARAMS).empty?
          raise InvalidParameters.new("Must be one of #{SUPPORTED_FIND_BY_PARAMS}")
        end
        raise InvalidParameters.new(":id takes precedent over :path, please only use one or the other") if params[:path] && params[:id]
        query = { path: params[:path], fileid: params[:id] }.compact
        parse_one(Client.execute("stat", query: query))
      end

      def upload(params)
        process_upload(params)
      end

      def upload!(params)
        process_upload(params.merge({ overwrite: true }))
      end

      private

      def process_upload(params)
        file = params.fetch(:file)
        raise InvalidParameter.new("The :file parameter must be an instance of Ruby `File`") unless file.is_a?(::File)

        # === pCloud API behavior notes: ===
        # 1. If neither `path` nor `folder_id` is provided, the file will be
        #    uploaded into the users root directory by default.
        # 2. If the `filename` does not match the name of the `file` provided,
        #    pCloud will use the name of the `file` rather than renaming it.
        response = Client.execute(
          "uploadfile",
          body: {
            renameifexists: params[:overwrite] ? 0 : 1,
            path: params[:path],
            folderid: params[:folder_id],
            filename: params.fetch(:filename),
            file: file,
          }.compact,
        )
        # This method on the pCloud API can accept multiple uploads at once.
        # For now, this upload interface just takes a single file at a time
        # so we return just one file out of this method.
        uploaded_file = parse_many(response).first
        raise UploadFailed if uploaded_file.nil?
        return uploaded_file
      rescue KeyError => e
        missing_param = e.message.gsub("key not found: ", "")
        raise MissingParameter.new("#{missing_param} is required")
      end
    end
  end
end
