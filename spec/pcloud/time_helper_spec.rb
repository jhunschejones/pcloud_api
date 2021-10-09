RSpec.describe Pcloud::TimeHelper do
  class TestClass
    include Pcloud::TimeHelper
  end

  # This method does not exist before Ruby 2.7. I'm adding it here so that the
  # test suite will work on older Ruby's. (The gem's code itself does not
  # depend on this method existing.)
  unless Time.method_defined? :floor
    class Time
      def floor(floor=0)
        Time.at(self.to_r.floor(floor))
      end
    end
  end

  let(:subject) { TestClass.new }
  let(:time) { Time.now }

  describe "#from_time" do
    it "returns a time object" do
      expect(subject.send(:time_from, time)).to be_a(Time)
    end

    it "parses a time object" do
      expect(subject.send(:time_from, time)).to eq(time.utc)
    end

    it "parses a string timestamp" do
      expect(subject.send(:time_from, time.to_s)).to eq(time.utc.floor(0))
    end

    it "parses an integer timestamp in seconds" do
      expect(subject.send(:time_from, time.to_i)).to eq(time.utc.floor(0))
    end

    it "parses an integer timestamp in milliseconds" do
      expect(
        subject.send(:time_from, (time.to_f * 1000).to_i)
      ).to eq(time.utc.floor(3))
    end

    it "respects the TZ environment varaible" do
      allow(ENV).to receive(:[]).with("TZ").and_return("America/Los_Angeles")
      expected_local_timezone_time = TZInfo::Timezone
        .get("America/Los_Angeles")
        .to_local(time)
      expect(subject.send(:time_from, time)).to eq(expected_local_timezone_time)
    end

    it "raises on unrecognized time format" do
      expect {
        subject.send(:time_from, Array(time.to_s))
      }.to raise_error(Pcloud::TimeHelper::UnrecognizedTimeFormat, "[\"#{time.to_s}\"]")
    end
  end
end
