module Pcloud
  module TimeHelper
    class UnrecognizedTimeFormat < StandardError; end

    TIMEZONE = TZInfo::Timezone.get(ENV.fetch("TZ", "UTC")).freeze

    protected

    def time_from(time)
      time_object =
        if time.is_a?(String)
          Time.parse(time)
        elsif time.is_a?(Integer)
          return Time.at(time) if time.digits.size < 13
          milliseconds = time.to_s[-3..-1].to_i
          seconds = time.to_s[0..-4].to_i
          # Older Ruby versions only support microseconds as the second
          # argument to Time.at/2
          Time.at(seconds, milliseconds * 1000)
        elsif time.is_a?(Time)
          time
        else
          raise Pcloud::TimeHelper::UnrecognizedTimeFormat.new(time.inspect)
        end
      TIMEZONE.to_local(time_object)
    end
  end
end
