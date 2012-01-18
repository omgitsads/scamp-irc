require 'scamp/message'

class Scamp
  module IRC
    class Message < Scamp::Message
      def valid?(conditions={})
        !ignore_message? &&
        channel_match?(conditions[:channel]) &&
        user_match?(conditions[:user])
      end

      def matches? trigger
        if adapter.required_prefix
          if satisfies_required_prefix?
            msg = body.split(adapter.required_prefix, 2)[1]
            match? trigger, msg
          else
            return false
          end
        else
          match? trigger, body
        end
      end

      private
        def channel_match?(condition)
          return true if condition.nil?

          if condition.is_a? Array
            return condition.include?(channel)
          else
            return channel.downcase == condition.to_s.downcase
          end
        end

        def user_match?(condition)
          return true if condition.nil?

          if condition.is_a? Array
            return (condition.include?(user))
          else
            return user.downcase == condition.to_s.downcase
          end
        end

        def ignore_message?
          if adapter.ignore_self?
            return user == adapter.user
          end
          return false
        end

        def satisfies_required_prefix?
          if adapter.required_prefix
            if adapter.required_prefix.is_a? String
              return true if adapter.required_prefix == body[0...adapter.required_prefix.length]
            elsif adapter.required_prefix.is_a? Regexp
              return true if adapter.required_prefix.match body
            end
            return false
          else
            return true
          end
        end
    end
  end
end
