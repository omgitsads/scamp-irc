require 'scamp/irc/connection'

class Scamp
  module IRC
    class Adapter < Scamp::Adapter
      def connect!
        @connection ||= Scamp::IRC::Connection.connect(self, config)
        @opts[:channels].each {|channel| @connection.message("JOIN ##{channel}")}
      end

      def dispatch event, message=nil
        puts "#{event} - #{message.inspect}"
        if message && event == :channel
          msg = Scamp::IRC::Message.new self, :body    => message.message,
                                              :channel => message.channel,
                                              :user    => message.nick

          channel = Scamp::IRC::Channel.new self, @connection, message

          push [channel, msg]
        end
      end

      def required_prefix
        @opts[:required_prefix]
      end

      def ignore_self?
        @opts[:ignore_self] || false
      end

      def user
        nick
      end

      def config
        @config ||= Isaac::Config.new(server, port, ssl?, password, nick, realname, "scamp", :production, verbose)
      end

      private
        def server
          @opts[:server] || "localhost"
        end

        def port
          @opts[:port] || 6667
        end

        def ssl?
          @opts[:ssl] || false
        end

        def password
          @opts[:password]
        end

        def nick
          @opts[:nick]
        end

        def realname
          @opts[:realname] || "Scamp Bot"
        end

        def verbose
          @bot.verbose
        end
    end
  end
end
