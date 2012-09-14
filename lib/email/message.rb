require 'digest/md5'
require 'uri'

require 'mail'
require 'mime/types'
require 'nokogiri'

module Email
  #
  # Represents the original Email message.
  #
  class Message

    attr_reader :path, :directory, :name

    #
    # Initializes the message.
    #
    # @param [String] path
    #   The path to the email message.
    #
    def initialize(path)
      @path      = path
      @directory = File.dirname(path)
      @name      = File.basename(path).chomp('.eml')

      @message = Mail.read(@path)
    end

    #
    # Calculates the MD5 checksum of an Email message.
    #
    # @param [String] path
    #   The path to the message.
    #
    # @return [String]
    #   The MD5 checksum in hexdigest.
    #
    def self.md5(path)
      Digest::MD5.file(path).hexdigest
    end

    #
    # Anonymizes sensitive information from the message.
    #
    # @return [String]
    #   The redacted email message.
    #
    def anonymize
      raw_message = File.read(@path)

      replace_with_xs = lambda { |string|
        raw_message.gsub!(string) do |match|
          'X' * match.length
        end
      }

      # redact all recipient addresses
      @message[:to].addresses.each(&replace_with_xs)

      # redact all recipient names
      @message[:to].display_names.compact.each(&replace_with_xs)

      return raw_message
    end

    #
    # Enumerates the bodies of the message.
    #
    # @yield [content_type, body]
    #   The given block will be passed each content-type and decoded body.
    #
    # @yieldparam [String] content_type
    #   The content-type of the body.
    #
    # @yieldparam [String] body
    #   The decoded body from the message.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
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

    #
    # Enumerates over each link within the message.
    #
    # @yield [link]
    #   The given block will be passed each link found within the message.
    #
    # @yieldparam [String] link
    #   An extracted URL from the message.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each_link(&block)
      return enum_for(__method__) unless block_given?

      each_body do |content_type,body|
        mime_type = MIME::Type.new(content_type)

        case mime_type.sub_type
        when 'html', 'xhtml'
          Nokogiri::HTML(body).search('//a[@href]').each do |a|
            yield a.attr('href')
          end
        when 'plain'
          URI.extract(body,['http','https'],&block)
        end
      end
    end

    #
    # The unique set of links within the message.
    #
    # @return [Set<String>]
    #   The set of unique links.
    #
    def links
      each_link.to_set
    end

    #
    # Enumerates over each URL within the message.
    #
    # @yield [url]
    #   The given block will be passed each URL found within the message.
    #
    # @yieldparam [URI] url
    #   An extracted URL from the message.
    #
    # @return [Enumerator]
    #   If no block is given, an Enumerator will be returned.
    #
    def each_url
      return enum_for(__method__) unless block_given?

      each_link do |link|
        begin
          yield URI(link)
        rescue URI::InvalidURIError
        end
      end
    end

    #
    # The unique set of URLs within the message.
    #
    # @return [Set<URI>]
    #   The set of unique URLs.
    #
    def urls
      each_url.to_set
    end

    alias path to_s

    protected

    #
    # Passes all additional method calls down to the `Mail::Message` object.
    #
    # @see http://rubydoc.info/gems/mail/Mail/Message
    #
    def method_missing(*arguments); @message.send(*arguments); end

  end
end
