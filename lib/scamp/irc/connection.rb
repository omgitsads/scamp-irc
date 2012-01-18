# This was shamelessly "borrowed" from isaac (https://github.com/vangberg/isaac)
# so that i could do a presentation on Scamp, i wanted to use the code, but it
# hadn't been releasd as of yet :(

class Scamp
  module IRC
    class Connection < EventMachine::Connection

      def self.connect(bot, config)
        EventMachine.connect(config.server, config.port, self, bot, config)
      end

      def initialize(bot, config)
        @bot, @config = bot, config
        @transfered = 0
        @registration = []
      end

      def post_init
        @data = ''
        @queue = Queue.new(self, @bot.config.server)
        message "PASS #{@config.password}" if @config.password
        message "NICK #{@config.nick}"
        message "USER #{@config.nick} 0 * :#{@config.realname}"
        @queue.lock
      end

      def receive_data(data)
        @data << data
        loop do
          line, rest = @data.split("\n", 2)
          return unless rest
          @data = rest
          parse line
        end
      end

      def parse(input)
        puts "<< #{input}" if @bot.config.verbose
        msg = Message.new(input)

        if ("001".."004").include? msg.command
          @registration << msg.command
          if registered?
            @queue.unlock
            @bot.dispatch(:connect)
          end
        elsif msg.command == "PRIVMSG"
          if msg.params.last == "\001VERSION\001"
            message "NOTICE #{msg.nick} :\001VERSION #{@bot.config.version}\001"
          end

          type = msg.channel? ? :channel : :private
          @bot.dispatch(type, msg)
        elsif msg.error?
          @bot.dispatch(:error, msg)
        elsif msg.command == "PING"
          @queue.unlock
          message "PONG :#{msg.params.first}"
        elsif msg.command == "PONG"
          @queue.unlock
        else
          event = msg.command.downcase.to_sym
          @bot.dispatch(event, msg)
        end
      end

      def registered?
        (("001".."004").to_a - @registration).empty?
      end

      def message(msg)
        @queue << msg
      end

      class Message
        attr_accessor :raw, :prefix, :command, :params

        def initialize(msg=nil)
          @raw = msg
          parse if msg
        end

        def numeric_reply?
          !!numeric_reply
        end

        def numeric_reply
          @numeric_reply ||= @command.match(/^\d\d\d$/)
        end

        def parse
          match = @raw.match(/(^:(\S+) )?(\S+)(.*)/)
          _, @prefix, @command, raw_params = match.captures

          raw_params.strip!
          if match = raw_params.match(/:(.*)/)
            @params = match.pre_match.split(" ")
            @params << match[1]
          else
            @params = raw_params.split(" ")
          end
        end

        def nick
          return unless @prefix
          @nick ||= @prefix[/^(\S+)!/, 1]
        end

        def user
          return unless @prefix
          @user ||= @prefix[/^\S+!(\S+)@/, 1]
        end

        def host
          return unless @prefix
          @host ||= @prefix[/@(\S+)$/, 1]
        end

        def server
          return unless @prefix
          return if @prefix.match(/[@!]/)
          @server ||= @prefix[/^(\S+)/, 1]
        end

        def error?
          !!error
        end

        def error
          return @error if @error
          @error = command.to_i if numeric_reply? && command[/[45]\d\d/]
        end

        def channel?
          !!channel
        end

        def channel
          return @channel if @channel
          if regular_command? and params.first.start_with?("#")
            @channel = params.first
          end
        end

        def message
          return @message if @message
          if error?
            @message = error.to_s
          elsif regular_command?
            @message = params.last
          end
        end

        private
        # This is a late night hack. Fix.
        def regular_command?
          %w(PRIVMSG JOIN PART QUIT).include? command
        end
      end

      class Queue
        def initialize(connection, server)
          # We need  server  for pinging us out of an excess flood
          @connection, @server = connection, server
          @queue, @lock, @transfered = [], false, 0
        end

        def lock
          @lock = true
        end

        def unlock
          @lock, @transfered = false, 0
          invoke
        end

        def <<(message)
          @queue << message
          invoke
        end

      private
        def message_to_send?
          !@lock && !@queue.empty?
        end

        def transfered_after_next_send
          @transfered + @queue.first.size + 2 # the 2 is for \r\n
        end

        def exceed_limit?
          transfered_after_next_send > 1472
        end

        def lock_and_ping
          lock
          @connection.send_data "PING :#{@server}\r\n"
        end

        def next_message
          @queue.shift.to_s.chomp + "\r\n"
        end

        def invoke
          while message_to_send?
            if exceed_limit?
              lock_and_ping; break
            else
              @transfered = transfered_after_next_send
              @connection.send_data next_message
              # puts ">> #{msg}" if @bot.config.verbose
            end
          end
        end
      end
    end
  end
end

