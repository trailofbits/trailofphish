require 'digest/md5'
require 'uri'

require 'mail'
require 'mime/types'
require 'nokogiri'

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
