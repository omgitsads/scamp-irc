require "rubygems"
require "bundler/setup"

require 'scamp'
require 'scamp/irc'

Scamp.new :verbose => true do |bot|
  bot.adapter :irc, Scamp::IRC::Adapter, :server => 'irc.freenode.net',
                                         :nick => 'scampv2',
                                         :channels => ["nwrug"]

  bot.match /^ping/ do |channel, msg|
    channel.reply "pong"
  end

  bot.connect!
end
