RSpec.describe Pcloud::Folder do
  let(:cat_photo) do
    Pcloud::File.new(
      id: 100100,
      name: "cats.jpg",
      path: "/cats.jpg",
      content_type: "image/jpg",
      category_id: 1, # image
      size: 1992312,
      parent_folder_id: 9000,
      is_deleted: false,
      created_at: "Sat, 25 Sep 2021 04:44:32 +0000",
      modified_at: "Sat, 25 Sep 2021 04:44:32 +0000"
    )
  end

  let(:jacks_folder) do
    Pcloud::Folder.new(
      id: 9000,
      path: "/jacks_folder",
      name: "jacks_folder",
      parent_folder_id: 0,
      contents: [cat_photo, jacks_subfolder],
      is_deleted: false,
      created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
      modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
    )
  end

  let(:jacks_subfolder) do
    Pcloud::Folder.new(
      id: 10000,
      path: "/jacks_subfolder",
      name: "jacks_subfolder",
      parent_folder_id: 9000,
      contents: [],
      is_deleted: false,
      created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
      modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
    )
  end

  describe "#initialize" do
    it "raises an error if a required attribute is missing from params" do
      expect {
        Pcloud::Folder.new(
          id: 10000,
          name: "jacks_subfolder",
          parent_folder_id: 9000,
          contents: [],
          is_deleted: false,
          created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
          modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
        )
      }.to raise_error(KeyError, "key not found: :path")
    end

    it "sets is_deleted default when param has nil value" do
      folder = Pcloud::Folder.new(
        id: 10000,
        path: "/jacks_subfolder",
        name: "jacks_subfolder",
        parent_folder_id: 9000,
        contents: [],
        is_deleted: nil,
        created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
        modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
      )
      expect(folder.is_deleted).to eq(false)
    end

    # Some APIs (mainly recursive operations according to pCloud) return either a
    # nil or an empty array of contents. In these cases, the @contents_are_confirmed
    # flag is set to `false` in order to allow one retry to fetch the actual
    # contents if the `contents` method is called on a folder object that does not
    # have any contents set yet.
    it "sets contents_are_confirmed to false on empty contents" do
      folder = Pcloud::Folder.new(
        id: 10000,
        path: "/jacks_subfolder",
        name: "jacks_subfolder",
        parent_folder_id: 9000,
        contents: [],
        is_deleted: false,
        created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
        modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
      )
      expect(folder.instance_variable_get(:@contents_are_confirmed)).to eq(false)
    end

    it "sets contents_are_confirmed to true when contents are present" do
      folder = Pcloud::Folder.new(
        id: 9000,
        path: "/jacks_folder",
        name: "jacks_folder",
        parent_folder_id: 0,
        contents: [cat_photo, jacks_subfolder],
        is_deleted: false,
        created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
        modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
      )
      expect(folder.instance_variable_get(:@contents_are_confirmed)).to eq(true)
    end
  end

  describe "#update" do
    context "when updating the name" do
      let(:rename_response) do
        {
          "metadata" => {
            "folderid" => 9000,
            "path" => "/jacks_cat_pictures",
            "name" => "jacks_cat_pictures",
            "parentfolderid" => 0,
            "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
            "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
            "contents" => [] # This API does not return the folder contents
          }
        }
      end

      before do
        allow(Pcloud::Client).to receive(:execute).and_return(rename_response)
      end

      it "makes a renamefolder request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "renamefolder",
            query: { folderid: 9000, toname: "jacks_cat_pictures" }
          )
        jacks_folder.update(name: "jacks_cat_pictures")
      end

      it "returns a Pcloud::Folder with updated name and no contents" do
        response = jacks_folder.update(name: "jacks_cat_pictures")
        expect(response).to be_a(Pcloud::Folder)
        expect(response.name).to eq("jacks_cat_pictures")
        expect(response.instance_variable_get(:@contents)).to eq([])
      end
    end

    context "when updating the parent_folder_id" do
      let(:folder_move_response) do
        {
          "metadata" => {
            "folderid" => 9000,
            "path" => nil, # This API does not return a folder path
            "name" => "jacks_folder",
            "parentfolderid" => 7000,
            "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
            "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
            "contents" => [] # This API does not return the folder contents
          }
        }
      end

      before do
        allow(Pcloud::Client).to receive(:execute).and_return(folder_move_response)
      end

      it "makes a renamefolder request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "renamefolder",
            query: { folderid: 9000, tofolderid: 7000 }
          )
        jacks_folder.update(parent_folder_id: 7000)
      end

      it "returns a Pcloud::Folder with updated parent_folder_id and no contents" do
        response = jacks_folder.update(parent_folder_id: 7000)
        expect(response).to be_a(Pcloud::Folder)
        expect(response.parent_folder_id).to eq(7000)
        expect(response.instance_variable_get(:@contents)).to eq([])
      end
    end

    context "when updating the path" do
      let(:folder_move_response) do
        {
          "metadata" => {
            "folderid" => 9000,
            "path" => nil, # This API really returns nil for the path
            "name" => "jacks_folder",
            "parentfolderid" => 7000,
            "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
            "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
            "contents" => [] # This API does not return the folder contents
          }
        }
      end

      before do
        allow(Pcloud::Client).to receive(:execute).and_return(folder_move_response)
      end

      it "makes a renamefolder request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "renamefolder",
            query: { folderid: 9000, topath: "/jack_images/" }
          )
        jacks_folder.update(path: "/jack_images/")
      end

      it "returns a Pcloud::Folder with in new parent folder but with nil path and no contents" do
        response = jacks_folder.update(path: "/jack_images/")
        expect(response).to be_a(Pcloud::Folder)
        expect(response.parent_folder_id).to eq(7000)
        expect(response.path).to eq(nil) # This is still the vaule we get when it worked!
        expect(response.instance_variable_get(:@contents)).to eq([])
      end
    end

    context "with unsuported update params" do
      it "raises InvalidParameters and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          jacks_folder.update(coolness_points: 1000000000)
        }.to raise_error(Pcloud::Folder::InvalidParameters, "Must be one of [:name, :parent_folder_id, :path]")
      end
    end

    context "with poorly formed path parameter" do
      it "raises InvalidParameter and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          jacks_folder.update(path: "/jack_images")
        }.to raise_error(Pcloud::Folder::InvalidParameter, ":path parameter must start and end with `/`")
      end
    end
  end

  describe "#delete" do
    let(:delete_response) do
      {
        "metadata" => {
          "folderid" => 10000,
          "path" => "/jacks_subfolder",
          "name" => "jacks_subfolder",
          "parentfolderid" => 9000,
          "contents" => [],
          "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
          "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
          "isdeleted" => true
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(delete_response)
    end

    it "makes a deletefolder request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "deletefolder",
          query: { folderid: 10000 }
        )
      jacks_subfolder.delete
    end

    it "returns the deleted Pcloud::Folder" do
      response = jacks_subfolder.delete
      expect(response).to be_a(Pcloud::Folder)
      expect(response.name).to eq("jacks_subfolder")
      expect(response.is_deleted).to eq(true)
    end
  end

  describe "#delete" do
    let(:delete_bang_response) do
      {
        "somenonsense" => "not_helpful"
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(delete_bang_response)
    end

    it "makes a deletefolderrecursive request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "deletefolderrecursive",
          query: { folderid: 9000 }
        )
      jacks_folder.delete!
    end

    it "just returns true" do
      expect(jacks_folder.delete!).to eq(true)
    end
  end

  describe "#parent_folder" do
    before do
      allow(Pcloud::Folder).to receive(:find).and_return(jacks_folder)
    end

    it "looks up the parent folder" do
      expect(Pcloud::Folder)
        .to receive(:find)
        .with(9000)
      jacks_subfolder.parent_folder
    end

    it "returns a Pcloud::Folder" do
      response = jacks_subfolder.parent_folder
      expect(response).to be_a(Pcloud::Folder)
      expect(response.id).to eq(9000)
      expect(response.name).to eq("jacks_folder")
    end

    it "caches the response" do
      expect(Pcloud::Folder).to receive(:find).once
      5.times { jacks_subfolder.parent_folder }
    end
  end

  describe "#contents" do
    let(:jacks_folder_no_confirmed_contents) { jacks_folder.dup }

    before do
      allow(Pcloud::Folder).to receive(:find).and_return(jacks_folder)
    end

    # Some APIs (mainly recursive operations according to pCloud) return either a
    # nil or an empty array of contents. In these cases, the @contents_are_confirmed
    # flag is set to `false` in order to allow one retry to fetch the actual
    # contents if the `contents` method is called on a folder object that does not
    # have any contents set yet.
    context "when no contents are present" do
      before do
        jacks_folder_no_confirmed_contents.instance_variable_set(:@contents, nil)
        jacks_folder_no_confirmed_contents.instance_variable_set(:@contents_are_confirmed, false)
      end

      it "makes a find request for the folder contents" do
        expect(Pcloud::Folder)
          .to receive(:find)
          .with(9000)
        jacks_folder_no_confirmed_contents.contents
      end

      it "returns the folder contents" do
        contents = jacks_folder_no_confirmed_contents.contents
        expect(contents.size).to eq(2)
        expect(contents.first).to be_a(Pcloud::File)
        expect(contents.last).to be_a(Pcloud::Folder)
      end

      it "caches the response" do
        expect(Pcloud::Folder).to receive(:find).once
        5.times { jacks_folder_no_confirmed_contents.contents }
      end
    end

    context "when contents are already present" do
      it "returns the folder contents" do
        contents = jacks_folder.contents
        expect(contents.size).to eq(2)
        expect(contents.first).to be_a(Pcloud::File)
        expect(contents.last).to be_a(Pcloud::Folder)
      end

      it "does not make an additional call to Pcloud::Folder.find()" do
        expect(Pcloud::Folder).to receive(:find).never
        jacks_folder.contents
      end
    end
  end

  describe ".first_or_create" do
    let(:create_response) do
      {
        "metadata" => {
          "folderid" => 9000,
          "path" => "/jacks_folder",
          "name" => "jacks_folder",
          "parentfolderid" => 0,
          "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
          "modified" => "Sun, 26 Sep 2021 21:26:06 +0000",
          "contents" => [] # this method on the API doesn't return contents, even if they really exist
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(create_response)
    end

    context "with `parent_folder_id` and `name` params" do
      it "makes a createfolderifnotexists request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "createfolderifnotexists",
            query: { folderid: 0, name: "jacks_folder" }
          )
        Pcloud::Folder.first_or_create(parent_folder_id: 0, name: "jacks_folder")
      end

      it "returns a Pcloud::Folder with no contents" do
        response = Pcloud::Folder.first_or_create(parent_folder_id: 0, name: "jacks_folder")
        expect(response).to be_a(Pcloud::Folder)
        expect(response.name).to eq("jacks_folder")
        expect(response.instance_variable_get(:@contents)).to eq([])
      end
    end

    context "with `path` param" do
      it "makes a createfolderifnotexists request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "createfolderifnotexists",
            query: { path: "/jacks_folder" }
          )
        Pcloud::Folder.first_or_create(path: "/jacks_folder")
      end

      it "returns a Pcloud::Folder with no contents" do
        response = Pcloud::Folder.first_or_create(path: "/jacks_folder")
        expect(response).to be_a(Pcloud::Folder)
        expect(response.name).to eq("jacks_folder")
        expect(response.instance_variable_get(:@contents)).to eq([])
      end
    end

    context "with invalid params" do
      it "raises and does not make an API call" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::Folder.first_or_create(name: "jacks_folder")
        }.to raise_error(
          Pcloud::Folder::InvalidParameters,
          "either :path or a combination of :parent_folder_id and :name params are required"
        )
      end
    end
  end

  describe ".exists?" do
    it "calls .find" do
      expect(Pcloud::Folder).to receive(:find).with(1)
      Pcloud::Folder.exists?(1)
    end

    it "returns false when no folder is found" do
      allow(Pcloud::Folder)
        .to receive(:find)
        .with(1)
        .and_raise(Pcloud::Client::ErrorResponse.new("Directory does not exist."))
      expect(Pcloud::Folder.exists?(1)).to eq(false)
    end

    it "returns true when a folder is found" do
      allow(Pcloud::Folder).to receive(:find).and_return(jacks_folder)
      expect(Pcloud::Folder.exists?(1)).to eq(true)
    end

    it "re-raises unexpected errors" do
      expected_error = Pcloud::Client::ErrorResponse.new("Folder contents are too funny.")
      allow(Pcloud::Folder)
        .to receive(:find)
        .with(1)
        .and_raise(expected_error)
      expect {
        Pcloud::Folder.exists?(1)
      }.to raise_error(expected_error)
    end
  end

  describe ".find" do
    let(:find_response) do
      {
        "metadata" => {
          "folderid" => 9000,
          "path" => "/jacks_folder",
          "name" => "jacks_folder",
          "parentfolderid" => 0,
          "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
          "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
          "contents" => [
            {
              "isfolder" => false,
              "fileid" => 100100,
              "name" => "more_cats.jpg",
              "path" => "/more_cats.jpg",
              "contenttype" => "image/jpg",
              "category" => 1,
              "size" => 1992312,
              "parentfolderid" => 0,
              "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
              "modified" => "Sat, 25 Sep 2021 05:44:32 +0000"
            },
            {
              "isfolder" => true,
              "folderid" => 10000,
              "name" => "jacks_subfolder",
              "parentfolderid" => 9000,
              "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
              "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
            },
          ]
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(find_response)
    end

    it "makes a listfolder request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "listfolder",
          query: { folderid: 9000 }
        )
      Pcloud::Folder.find(9000)
    end

    it "returns a Pcloud::Folder" do
      response = Pcloud::Folder.find(9000)
      expect(response).to be_a(Pcloud::Folder)
      expect(response.name).to eq("jacks_folder")
    end

    it "returns the contents of the folder" do
      contents = Pcloud::Folder.find(9000).contents
      expect(contents.size).to eq(2)
      expect(contents.first).to be_a(Pcloud::File)
      expect(contents.last).to be_a(Pcloud::Folder)
    end
  end

  describe ".find_by" do
    let(:find_by_response) do
      {
        "metadata" => {
          "folderid" => 9000,
          "path" => "/jacks_folder",
          "name" => "jacks_folder",
          "parentfolderid" => 0,
          "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
          "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
          "contents" => [
            {
              "isfolder" => false,
              "fileid" => 100100,
              "name" => "more_cats.jpg",
              "path" => "/more_cats.jpg",
              "contenttype" => "image/jpg",
              "category" => 1,
              "size" => 1992312,
              "parentfolderid" => 0,
              "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
              "modified" => "Sat, 25 Sep 2021 05:44:32 +0000"
            },
            {
              "isfolder" => true,
              "folderid" => 10000,
              "name" => "jacks_subfolder",
              "parentfolderid" => 9000,
              "created" => "Sun, 26 Sep 2021 21:26:06 +0000",
              "modified" => "Sun, 26 Sep 2021 22:26:06 +0000",
            },
          ]
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(find_by_response)
    end

    it "makes a listfolder request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "listfolder",
          query: { path: "/jacks_folder" }
        )
      Pcloud::Folder.find_by(path: "/jacks_folder")
    end

    it "returns a Pcloud::Folder" do
      response = Pcloud::Folder.find_by(path: "/jacks_folder")
      expect(response).to be_a(Pcloud::Folder)
      expect(response.name).to eq("jacks_folder")
    end

    it "returns the contents of the folder" do
      contents = Pcloud::Folder.find_by(path: "/jacks_folder").contents
      expect(contents.size).to eq(2)
      expect(contents.first).to be_a(Pcloud::File)
      expect(contents.last).to be_a(Pcloud::Folder)
    end

    context "with invalid parameters" do
      it "raises InvalidParameters and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::Folder.find_by(feeling: "happy")
        }.to raise_error(Pcloud::Folder::InvalidParameters, "Must be one of [:id, :path]")
      end
    end

    context "when both path and id parameters are passed" do
      it "raises InvalidParameters and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::Folder.find_by(path: "/jacks_folder", id: 9000)
        }.to raise_error(
          Pcloud::Folder::InvalidParameters,
          ":id takes precedent over :path, please only use one or the other"
        )
      end
    end
  end
end
