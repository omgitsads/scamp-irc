class Scamp
  module IRC
    class Channel
      attr_reader :adapter, :message

      def initialize adapter, msg
        @adapter = adapter
        @message = msg
      end

      def say msg, *rooms
        if rooms.empty?
          message.room.speak msg
        else
          rooms.each do |room|
            r = adapter.room(room)
            r.speak msg
          end
        end
      end

      def reply msg
        message.room.speak "#{message.user.name}: #{msg}"
      end

      def paste text, *rooms
        if rooms.empty?
          message.room.paste text
        else
          rooms.each do |room|
            r = adapter.room(room)
            r.paste text
          end
        end
      end

      def play sound, *rooms
        if rooms.empty?
          message.room.play sound.to_s
        else
          rooms.each do |room|
            r = adapter.room(room)
            r.play sound.to_s
          end
        end

      end

      %w(crickets drama greatjob live nyan pushit rimshot secret tada tmyk trombone vuvuzela yeah).each do |sound|
        define_method sound do
          play sound
        end
      end
    end
  end
end
