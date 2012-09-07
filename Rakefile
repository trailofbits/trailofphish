require 'rubygems'
require 'digest/md5'
require 'uri'
require 'set'

require 'mail'
require 'mime/types'
require 'nokogiri'
require 'mechanize'

module Email
  class Message

    attr_reader :path, :directory, :name

    def initialize(path)
      @path      = path
      @directory = File.dirname(path)
      @name      = File.basename(path).chomp('.eml')

      @message = Mail.read(@path)
    end

    def self.md5(path)
      Digest::MD5.file(path).hexdigest
    end

    def each_body
      return enum_for(__method__) unless block_given?

      unless @message.body.parts.empty?
        @message.body.parts.each do |part|
          yield part.content_type, part.body.decoded
        end
      else
        yield @message.content_type, @message.body.decoded
      end
    end

    def each_link(&block)
      return enum_for(__method__) unless block_given?

      each_body do |content_type,body|
        mime_type = MIME::Type.new(content_type)

        case mime_type.sub_type
        when 'html', 'xhtml'
          Nokogiri::HTML(body).search('//a/@href').each do |attr|
            yield attr.value
          end
        when 'plain'
          URI.extract(body,&block)
        end
      end
    end

    def links
      each_link.to_set
    end

    alias path to_s

    protected

    def method_missing(*arguments); @message.send(*arguments); end

  end
end

Dir.glob('originals/*') do |category|
  Dir.glob(File.join(category,'*.eml')) do |original_path|
    message_dir  = File.join(File.basename(category),Email::Message.md5(original_path))
    message_path = File.join(message_dir,'message.eml')

    directory message_dir

    file message_path => [message_dir, original_path] do
      raw_email = File.read(original_path)
      email     = Email::Message.new(original_path)

      puts ">>> Anonymizing #{message_path} ..."

      File.open(message_path,'w') do |file|
        sensitive = email[:to].addresses

        file << raw_email.gsub(Regexp.union(sensitive)) do |match|
          'X' * match.length
        end
      end
    end

    desc "Anonymizes all original emails"
    task :anonymize => message_path

    links_dir = File.join(message_dir,'links')

    file links_dir => message_dir do
      email = Email::Message.new(message_path)

      browser = Mechanize.new
      browser.pluggable_parser.default = Mechanize::Download

      mkdir_p links_dir

      email.links.each do |url|
        uri = URI(url)

        output = File.join(links_dir,uri.host,uri.request_uri)
        FileUtils.mkdir_p File.dirname(output)

        puts ">>> Downloading #{url} ..."
        browser.get(url).save(output)
      end
    end

    desc "Extracts links from all emails"
    task 'extract:links' => links_dir

    attachments_dir = File.join(message_dir,'attachments')

    file attachments_dir => message_dir do
      email = Email::Message.new(message_path)

      mkdir attachments_dir

      email.attachments.each do |attachment|
        puts ">>> Extracting attachment #{attachment.filename} ..."

        File.open(File.join(attachments_dir,attachment.filename),'wb') do |file|
          file.write attachment.body.to_s
        end
      end
    end

    desc "Extracts attachments from all emails"
    task 'extract:attachments' => attachments_dir

    zipfile = "#{message_dir}.zip"

    file zipfile => [message_path, links_dir, attachments_dir] do
      sh 'zip', '-r', '-P', 'infected', zipfile, message_dir
    end

    desc "Creates zip archives of all emails"
    task :zip => zipfile
  end
end
