module Pcloud
  class Folder
    class UnsuportedUpdateParams < StandardError; end
    class ManformedUpdateParams < StandardError; end
    class InvalidCreateParams < StandardError; end
    class MissingParameter < StandardError; end

    include Parser
    include Pcloud::TimeHelper

    SUPPORTED_UPDATE_PARAMS = [:name, :parent_folder_id, :path].freeze

    attr_reader :id, :path, :name, :parent_folder_id, :is_deleted, :created_at,
                :modified_at

    def initialize(params)
      @id = params.fetch(:id)
      @path = params.fetch(:path)
      @name = params.fetch(:name)
      @parent_folder_id = params.fetch(:parent_folder_id)
      @contents = params.fetch(:contents)
      # Some APIs (mainly recursive operations according to pCloud) return either a
      # nil or an empty array of contents. In these cases, the @contents_are_confirmed
      # flag is set to `false` in order to allow one retry to fetch the actual
      # contents if the `contents` method is called on a folder object that does not
      # have any contents set yet.
      @contents_are_confirmed = @contents && @contents.size > 0
      @is_deleted = params.fetch(:is_deleted) || false
      @created_at = time_from(params.fetch(:created_at))
      @modified_at = time_from(params.fetch(:modified_at))
    end

    def update(params)
      unless (params.keys - SUPPORTED_UPDATE_PARAMS).empty?
        raise UnsuportedUpdateParams.new("Must be one of #{SUPPORTED_UPDATE_PARAMS}")
      end
      if params[:path] && is_invalid_path_param?(params[:path])
        raise ManformedUpdateParams.new("`path` param must start and end with `/`")
      end
      query = {
        folderid: id,
        tofolderid: params[:parent_folder_id] || nil,
        toname: params[:name] || nil,
        topath: params[:path] || nil
      }.compact
      parse_one(Client.execute("renamefolder", query: query))
    end

    # This method is the safest way to delte folders and will fail if the folder
    # has contents.
    def delete
      parse_one(Client.execute("deletefolder", query: { folderid: id }))
    end

    # This method will delete a folder and recursively delete all its contents
    def delete!
      Client.execute("deletefolderrecursive", query: { folderid: id })
      true # we don't get anything helpful back from pCloud on this request
    end

    def parent_folder
      @parent_folder ||= Folder.find(parent_folder_id)
    end

    # Some APIs return `nil` or `[]` for contents when a folder does actually
    # have contents. This method allows us to re-try one time if we try to get
    # the contents and find that they're missing.
    def contents
      return @contents if @contents_are_confirmed
      @contents = Folder.find(id).contents
      @contents_are_confirmed = true
      @contents
    end

    private

    def is_invalid_path_param?(path_param)
      # Path params have to start and end with `/`
      [path_param[0], path_param[-1]] != ["/", "/"]
    end

    class << self
      def first_or_create(params)
        if params[:parent_folder_id] && params[:name]
          parse_one(Client.execute("createfolderifnotexists", query: { folderid: params[:parent_folder_id], name: params[:name] }))
        elsif params[:path]
          parse_one(Client.execute("createfolderifnotexists", query: { path: params[:path] }))
        else
          raise InvalidCreateParams.new("first_or_create must be called with either `path` or both `parent_folder_id` and `name` params")
        end
      end

      def exists?(id)
        find(id)
        true
      rescue Pcloud::Client::ErrorResponse => e
        return false if e.message == "Directory does not exist."
        raise e
      end

      def find(id)
        find_by(id: id)
      end

      def find_by(params)
        raise MissingParameter.new(":path or :id is required") unless params[:path] || params[:id]
        parse_one(
          Client.execute(
            "listfolder",
            query: { path: params[:path], folderid: params[:id] }.compact
          )
        )
      end
    end
  end
end
