RSpec.describe Pcloud::File do
  let(:cat_photo) do
    Pcloud::File.new(
      id: 100100,
      name: "cats.jpg",
      path: "/cats.jpg",
      content_type: "image/jpg",
      category_id: 1, # image
      size: 1992312,
      parent_folder_id: 0,
      is_deleted: false,
      created_at: "Sat, 25 Sep 2021 04:44:32 +0000",
      modified_at: "Sat, 25 Sep 2021 04:44:32 +0000"
    )
  end

  describe "#initialize" do
    it "raises an error if a required attribute is missing from params" do
      expect {
        Pcloud::File.new(
          id: 100100,
          name: "cats.jpg",
          content_type: "image/jpg",
          category_id: 1,
          size: 1992312,
          parent_folder_id: 0,
          is_deleted: false,
          created_at: "Sat, 25 Sep 2021 04:44:32 +0000",
          modified_at: "Sat, 25 Sep 2021 04:44:32 +0000"
        )
      }.to raise_error(KeyError, "key not found: :path")
    end

    it "sets catagory and is_deleted defaults on nil values" do
      file = Pcloud::File.new(
        id: 100100,
        name: "cats.jpg",
        path: "/cats.jpg",
        content_type: "image/jpg",
        category_id: nil,
        size: 1992312,
        parent_folder_id: 0,
        is_deleted: nil,
        created_at: "Sat, 25 Sep 2021 04:44:32 +0000",
        modified_at: "Sat, 25 Sep 2021 04:44:32 +0000"
      )
      expect(file.category).to eq("uncategorized")
      expect(file.is_deleted).to eq(false)
    end
  end

  describe "#update" do
    context "when updating the name" do
      let(:rename_response) do
        {
          "metadata" => {
            "fileid" => 100100,
            "name" => "more_cats.jpg",
            "path" => "/more_cats.jpg",
            "contenttype" => "image/jpg",
            "category" => 1,
            "size" => 1992312,
            "parentfolderid" => 0,
            "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
            "modified" => "Sat, 25 Sep 2021 05:44:32 +0000"
          }
        }
      end

      before do
        allow(Pcloud::Client).to receive(:execute).and_return(rename_response)
      end

      it "makes a filelink request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "renamefile",
            query: { fileid: cat_photo.id, toname: "more_cats.jpg" }
          )
        cat_photo.update(name: "more_cats.jpg")
      end

      it "returns a Pcloud::File with updated name" do
        response = cat_photo.update(name: "more_cats.jpg")
        expect(response).to be_a(Pcloud::File)
        expect(response.name).to eq("more_cats.jpg")
      end
    end

    context "when updating the parent_folder_id" do
      let(:move_response) do
        {
          "metadata" => {
            "fileid" => 100100,
            "name" => "cats.jpg",
            "path" => "/images/cats.jpg",
            "contenttype" => "image/jpg",
            "category" => 1,
            "size" => 1992312,
            "parentfolderid" => 9000,
            "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
            "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
          }
        }
      end

      before do
        allow(Pcloud::Client).to receive(:execute).and_return(move_response)
      end

      it "makes a filelink request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "renamefile",
            query: { fileid: cat_photo.id, tofolderid: 9000 }
          )
        cat_photo.update(parent_folder_id: 9000)
      end

      it "returns a Pcloud::File with updated parent_folder_id" do
        response = cat_photo.update(parent_folder_id: 9000)
        expect(response).to be_a(Pcloud::File)
        expect(response.parent_folder_id).to eq(9000)
      end
    end

    context "when updating the path" do
      let(:move_response) do
        {
          "metadata" => {
            "fileid" => 100100,
            "name" => "cats.jpg",
            "path" => "/images/cats.jpg",
            "contenttype" => "image/jpg",
            "category" => 1,
            "size" => 1992312,
            "parentfolderid" => 9000,
            "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
            "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
          }
        }
      end

      before do
        allow(Pcloud::Client).to receive(:execute).and_return(move_response)
      end

      it "makes a filelink request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "renamefile",
            query: { fileid: cat_photo.id, topath: "/images/" }
          )
        cat_photo.update(path: "/images/")
      end

      it "returns a Pcloud::File with updated parent folder" do
        response = cat_photo.update(path: "/images/")
        expect(response).to be_a(Pcloud::File)
        expect(response.parent_folder_id).to eq(9000)
      end
    end

    context "with unsupported update params" do
      it "raises InvalidParameters and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          cat_photo.update(coolness_points: 1000000000)
        }.to raise_error(Pcloud::File::InvalidParameters, "Must be one of [:name, :parent_folder_id, :path]")
      end
    end

    context "with incorrectly formed update params" do
      it "raises InvalidParameter and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          cat_photo.update(path: "images")
        }.to raise_error(Pcloud::File::InvalidParameter, ":path param must start with `/`")
      end
    end
  end

  describe "#delete" do
    let(:delete_response) do
      {
        "metadata" => {
          "fileid" => 100100,
          "name" => "cats.jpg",
          "path" => "/cats.jpg",
          "contenttype" => "image/jpg",
          "category" => 1,
          "size" => 1992312,
          "parentfolderid" => 0,
          "isdeleted" => true,
          "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
          "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(delete_response)
    end

    it "makes a filelink request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "deletefile",
          query: { fileid: cat_photo.id }
        )
      cat_photo.delete
    end

    it "returns a Pcloud::File with updated is_deleted value" do
      response = cat_photo.delete
      expect(response).to be_a(Pcloud::File)
      expect(response.is_deleted).to eq(true)
    end
  end

  describe "#parent_folder" do
    let(:parent_folder) do
      Pcloud::Folder.new(
        id: 0,
        path: nil,
        name: "/",
        parent_folder_id: nil,
        contents: [],
        is_deleted: false,
        created_at: "Sun, 26 Sep 2021 21:26:06 +0000",
        modified_at: "Sun, 26 Sep 2021 21:26:06 +0000"
      )
    end

    before do
      allow(Pcloud::Folder).to receive(:find).and_return(parent_folder)
    end

    it "looks up the parent folder" do
      expect(Pcloud::Folder)
        .to receive(:find)
        .with(cat_photo.parent_folder_id)
      cat_photo.parent_folder
    end

    it "returns a Pcloud::Folder" do
      response = cat_photo.parent_folder
      expect(response).to be_a(Pcloud::Folder)
      expect(response.id).to eq(0)
      expect(response.name).to eq("/")
    end

    it "caches the response" do
      expect(Pcloud::Folder).to receive(:find).once
      5.times { cat_photo.parent_folder }
    end
  end

  describe "#download_url" do
    let(:filelink_response) do
      {
        "hosts" => ["download.the.files/"],
        "path" => "wherewekeepthefiles"
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(filelink_response)
      # Using a file name with spaces to insure that the name gets escaped
      # in the final download url
      cat_photo.instance_variable_set(:@name, "A Wonderful Cat Photo.jpg")
    end

    it "makes a filelink request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "getfilelink",
          query: { fileid: cat_photo.id, forcedownload: 1, skipfilename: 1 }
        )
      cat_photo.download_url
    end

    it "builds a browser-safe link from the pCloud filelink response" do
      expect(cat_photo.download_url)
        .to eq("https://download.the.files/wherewekeepthefiles/A+Wonderful+Cat+Photo.jpg")
    end

    it "caches the value" do
      expect(Pcloud::Client).to receive(:execute).once
      5.times { cat_photo.download_url }
    end
  end

  describe ".exists?" do
    it "calls .find" do
      expect(Pcloud::File).to receive(:find).with(1)
      Pcloud::File.exists?(1)
    end

    it "returns false when no file is found" do
      allow(Pcloud::File)
        .to receive(:find)
        .with(1)
        .and_raise(Pcloud::Client::ErrorResponse.new("File not found."))
      expect(Pcloud::File.exists?(1)).to eq(false)
    end

    it "returns true when a file is found" do
      allow(Pcloud::File).to receive(:find).and_return(cat_photo)
      expect(Pcloud::File.exists?(1)).to eq(true)
    end

    it "re-raises unexpected errors" do
      expected_error = Pcloud::Client::ErrorResponse.new("File is too funny.")
      allow(Pcloud::File)
        .to receive(:find)
        .with(1)
        .and_raise(expected_error)
      expect {
        Pcloud::File.exists?(1)
      }.to raise_error(expected_error)
    end
  end

  describe ".find" do
    let(:stat_response) do
      {
        "metadata" => {
          "fileid" => 100100,
          "name" => "cats.jpg",
          "path" => "/cats.jpg",
          "contenttype" => "image/jpg",
          "category" => 1,
          "size" => 1992312,
          "parentfolderid" => 0,
          "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
          "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(stat_response)
    end

    it "makes a stat request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "stat",
          query: { fileid: 100100 }
        )
      Pcloud::File.find(100100)
    end

    it "returns the expected Pcloud::File" do
      response = Pcloud::File.find(100100)
      expect(response).to be_a(Pcloud::File)
      expect(response.id).to eq(cat_photo.id)
      expect(response.name).to eq(cat_photo.name)
    end
  end

  describe ".find_by" do
    let(:stat_response) do
      {
        "metadata" => {
          "fileid" => 100100,
          "name" => "cats.jpg",
          "path" => "/cats.jpg",
          "contenttype" => "image/jpg",
          "category" => 1,
          "size" => 1992312,
          "parentfolderid" => 0,
          "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
          "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
        }
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(stat_response)
    end

    it "makes a stat request" do
      expect(Pcloud::Client)
        .to receive(:execute)
        .with(
          "stat",
          query: { path: "/cats.jpg" }
        )
      Pcloud::File.find_by(path: "/cats.jpg")
    end

    it "returns the expected Pcloud::File" do
      response = Pcloud::File.find_by(path: "/cats.jpg")
      expect(response).to be_a(Pcloud::File)
      expect(response.id).to eq(cat_photo.id)
      expect(response.name).to eq(cat_photo.name)
    end

    context "with invalid parameters" do
      it "raises InvalidParameters and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::File.find_by(feeling: "happy")
        }.to raise_error(Pcloud::File::InvalidParameters, "Must be one of [:id, :path]")
      end
    end

    context "when both id and path parameters are provided" do
      it "raises InvalidParameters and does not make a web request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::File.find_by(path: "/cats.jpg", id: 100100)
        }.to raise_error(
          Pcloud::File::InvalidParameters,
          ":id takes precedent over :path, please only use one or the other"
        )
      end
    end
  end

  describe ".upload" do
    let(:upload_response) do
      {
        "metadata" => [
          {
            "fileid" => 100100,
            "name" => "sleepy_cat.jpg",
            "path" => "/sleepy_cat.jpg",
            "contenttype" => "image/jpg",
            "category" => 1,
            "size" => 1992312,
            "parentfolderid" => 0,
            "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
            "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
          }
        ]
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(upload_response)
    end

    it "requires a file param" do
      expect {
        Pcloud::File.upload(my_file: "sleepy_cat.jpg")
      }.to raise_error(Pcloud::File::MissingParameter, ":file is required")
    end

    context "with a valid file object" do
      let(:sleepy_cat_image_file) { File.open("spec/fixtures/sleepy_cat.jpg") }

      it "makes an uploadfile request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "uploadfile",
            body: {
              renameifexists: 1,
              path: "/",
              folderid: 0,
              filename: "sleepy_cat.jpg",
              file: sleepy_cat_image_file
            }
          )
        Pcloud::File.upload(
          filename: "sleepy_cat.jpg",
          file: sleepy_cat_image_file,
          path: "/",
          folder_id: 0
        )
      end

      it "returns the expected Pcloud::File" do
        response = Pcloud::File.upload(
          filename: "sleepy_cat.jpg",
          file: sleepy_cat_image_file,
          path: "/",
          folder_id: 0
        )
        expect(response).to be_a(Pcloud::File)
        expect(response.id).to eq(100100)
        expect(response.name).to eq("sleepy_cat.jpg")
      end

      context "when the file upload fails" do
        it "raises Pcloud::File::UploadFailed" do
          allow(Pcloud::Client)
            .to receive(:execute)
            .and_return({ "result" => 0, "metadata" => [], "checksums" => [], "fileids" => [] })
          expect {
            Pcloud::File.upload(
              filename: "sleepy_cat.jpg",
              file: sleepy_cat_image_file,
              path: "/",
              folder_id: 0
            )
          }.to raise_error(Pcloud::File::UploadFailed)
        end
      end
    end

    context "with an invalid file object" do
      it "raises Pcloud::File::InvalidParameter and does not make an API request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::File.upload(
            filename: "sleepy_cat.jpg",
            file: "This is not a file.jpg",
            path: "/",
            folder_id: 0
          )
        }.to raise_error(Pcloud::File::InvalidParameter, "The :file parameter must be an instance of Ruby `File`")
      end
    end
  end

  describe ".upload!" do
    let(:upload_response) do
      {
        "metadata" => [
          {
            "fileid" => 100100,
            "name" => "sleepy_cat.jpg",
            "path" => "/sleepy_cat.jpg",
            "contenttype" => "image/jpg",
            "category" => 1,
            "size" => 1992312,
            "parentfolderid" => 0,
            "created" => "Sat, 25 Sep 2021 04:44:32 +0000",
            "modified" => "Sat, 25 Sep 2021 04:44:32 +0000"
          }
        ]
      }
    end

    before do
      allow(Pcloud::Client).to receive(:execute).and_return(upload_response)
    end

    context "with a valid file object" do
      let(:sleepy_cat_image_file) { File.open("spec/fixtures/sleepy_cat.jpg") }

      it "makes an uploadfile request" do
        expect(Pcloud::Client)
          .to receive(:execute)
          .with(
            "uploadfile",
            body: {
              renameifexists: 0,
              path: "/",
              folderid: 0,
              filename: "sleepy_cat.jpg",
              file: sleepy_cat_image_file
            }
          )
        Pcloud::File.upload!(
          filename: "sleepy_cat.jpg",
          file: sleepy_cat_image_file,
          path: "/",
          folder_id: 0
        )
      end

      it "returns the expected Pcloud::File" do
        response = Pcloud::File.upload!(
          filename: "sleepy_cat.jpg",
          file: sleepy_cat_image_file,
          path: "/",
          folder_id: 0
        )
        expect(response).to be_a(Pcloud::File)
        expect(response.id).to eq(100100)
        expect(response.name).to eq("sleepy_cat.jpg")
      end

      context "when the file upload fails" do
        it "raises Pcloud::File::UploadFailed" do
          allow(Pcloud::Client)
            .to receive(:execute)
            .and_return({ "result" => 0, "metadata" => [], "checksums" => [], "fileids" => [] })
          expect {
            Pcloud::File.upload!(
              filename: "sleepy_cat.jpg",
              file: sleepy_cat_image_file,
              path: "/",
              folder_id: 0
            )
          }.to raise_error(Pcloud::File::UploadFailed)
        end
      end
    end

    context "with an invalid file object" do
      it "raises Pcloud::File::InvalidParameter and does not make an API request" do
        expect(Pcloud::Client).to receive(:execute).never
        expect {
          Pcloud::File.upload(
            filename: "sleepy_cat.jpg",
            file: "This is not a file.jpg",
            path: "/",
            folder_id: 0
          )
        }.to raise_error(Pcloud::File::InvalidParameter, "The :file parameter must be an instance of Ruby `File`")
      end
    end
  end
end
