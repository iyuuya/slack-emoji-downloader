# frozen_string_literal: true

require 'bundler'
Bundler.setup

require 'slack'
require 'fileutils'
require 'open-uri'

def bulk_download(token)
  client = Slack::Client.new(token: token)

  unless client.auth_test['ok']
    puts "invalid-token: #{token}"
    exit
  end

  domain = client.team_info['team']['domain']

  download_dir = "emoji/#{domain}"
  FileUtils.mkdir_p(download_dir) unless Dir.exist?(download_dir)
  Dir.chdir(download_dir) do
    client.emoji_list['emoji'].each do |emoji, url|
      if url =~ /^alias:/
        puts "skip-alias: #{emoji}"
        next
      end

      emoji_filename = emoji + File.extname(url)

      if File.exist?(emoji_filename)
        puts "skip-file-exist: #{emoji_filename}"
        next
      end

      puts "download: #{emoji_filename}"
      open(emoji_filename, 'wb') do |emoji_file|
        open(url) do |raw|
          emoji_file.write(raw.read)
        end
      end
    end
  end
end

tokens = if ENV['TOKENS']
           ENV['TOKENS'].split(',')
         else
           print 'Tokens(separate comma): '
           gets.strip.split(',')
         end

tokens.each do |token|
  bulk_download(token)
end
