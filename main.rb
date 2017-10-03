# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'slack'
require 'fileutils'
require 'open-uri'

token = if ENV['TOKEN']
          ENV['TOKEN']
        else
          print 'Token: '
          gets.strip
        end

client = Slack::Client.new(token: token)

unless client.auth_test['ok']
  puts 'invalid token'
  exit
end

domain = client.team_info['team']['domain']

download_dir = "emoji/#{domain}"
FileUtils.mkdir_p(download_dir) unless Dir.exist?(download_dir)
Dir.chdir(download_dir) do
  client.emoji_list['emoji'].each do |emoji, url|
    if url =~ /^alias:/
      puts "skip: #{emoji}"
      next
    end

    emoji_filename = emoji + File.extname(url)
    puts "download: #{emoji_filename}"
    open(emoji_filename, 'wb') do |emoji_file|
      open(url) do |raw|
        emoji_file.write(raw.read)
      end
    end
  end
end
