#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'json'
require 'date'
require 'systemu'
require 'hipchat'

before do
  #client = HipChat::Client.new(api_token)
  client = HipChat::Client.new(ENV['HIPCHAT_API_TOKEN'])
end

get '/' do
  "Hi, I'm imode2hipchat! \n#{`date`}"
end

get '/test' do
  "Hi, I'm imode2hipchat! \n#{`date`}"
end

get '/hipchat' do
  client = HipChat::Client.new(ENV['HIPCHAT_API_TOKEN'])
  html = '<?xml version="1.0" encoding="Shift_JIS"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="ja" xml:lang="ja">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
  </head>
  <body>
    <form action="./hipchat" method="post" name="sender">
      <input type="text" name="message" value="" istyle="1">
      <input type="submit" value="send">
    </form>'

  # Get history from a room
  messages = JSON.parse(client[ENV['ROOM_NAME']].history())['messages']
  messages.reverse.each { |msg|
    date = (DateTime.parse(msg['date']) + Rational(9,24)).strftime("%m-%d %H:%M")
    user = msg['from']['name'].gsub(/(\s)+/, '')
    text = msg['message'].gsub("\\n", "<br />")
    html << "<p style='color: black;'>[#{date}] #{user.sub("インコモフモフ", "")}:<br />#{text}</p>"
  }

  html << "
 </body>
</html>
"
  puts html
  html
end

post '/hipchat' do
  puts params[:message]

  # client = HipChat::Client.new(api_token)
  client = HipChat::Client.new(ENV['HIPCHAT_API_TOKEN'])
  client[ENV['ROOM_NAME']].send('yasulabot', "#{params[:message]} (from Mobile)",
                     :color => 'yellow',
                     :notify => true,
                     :message_format => 'text')

  redirect '/hipchat'
end
