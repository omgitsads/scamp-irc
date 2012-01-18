class Scamp
  module IRC
    class Channel
      attr_reader :adapter, :channel, :message

      def initialize adapter, connection, message
        @adapter = adapter
        @connection = connection
        @channel = message.channel
        @message = message
      end

      def say msg, *channels
        if channels.empty?
          @connection.message "PRIVMSG #{channel} :#{msg}"
        else
          channels.each {|chan| @connection.message "PRIVMSG #{chan} :#{msg}"}
        end
      end

      def reply msg
        say "#{message.nick}: #{msg}"
      end
    end
  end
end
