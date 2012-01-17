class Scamp
  module IRC
    class Adapter < Scamp::Adapter
      def connect!
        rooms.each do |room|
          room.listen do |message|
            msg = Scamp::IRC::Message.new self, :body => message[:body],
                                                :room => channel,
                                                :user => message[:user],
                                                :type => message[:type]

            channel = Scamp::IRC::Channel.new self, msg

            push [channel, msg]
          end
        end
      end

      def required_prefix
        @opts[:required_prefix]
      end

      def ignore_self?
        @opts[:ignore_self] || false
      end

      def user
        connection.me
      end

      def room name_or_id
        if name_or_id.is_a? Fixnum
          connection.find_room_by_id name_or_id
        else
          connection.find_room_by_name name_or_id
        end
      end

      private
        def rooms
          @opts[:rooms].map do |room|
            if room.is_a? String
              connection.find_room_by_name room
            else
              connection.find_room_by_id room
            end
          end
        end

        def connection
          @connection ||= Tinder::Campfire.new @opts[:subdomain], :token => @opts[:api_key]
        end
    end
  end
end
