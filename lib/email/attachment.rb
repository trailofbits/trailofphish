require 'digest/md5'
require 'digest/sha1'
require 'digest/sha2'
# require 'ssdeep'
require 'magic'

module Email
  #
  # Represents an extracted attachment.
  #
  class Attachment

    attr_reader :path, :name

    #
    # Initializes the attachment.
    #
    # @param [String] path
    #   The path to the attachment.
    #
    def initialize(path)
      @path = path
      @name = File.basename(path)
    end

    #
    # The MD5 checksum of the attachment.
    #
    # @return [String]
    #   MD5 checksum in hex-digest format.
    #
    def md5;    Digest::MD5.file(@path).hexdigest;    end

    #
    # The SHA1 checksum of the attachment.
    #
    # @return [String]
    #   SHA1 checksum in hex-digest format.
    #
    def sha1;   Digest::SHA1.file(@path).hexdigest;   end

    #
    # The SHA256 checksum of the attachment.
    #
    # @return [String]
    #   SHA256 checksum in hex-digest format.
    #
    def sha256; Digest::SHA256.file(@path).hexdigest; end

    #
    # The SHA512 checksum of the attachment.
    #
    # @return [String]
    #   SHA512 checksum in hex-digest format.
    #
    def sha512; Digest::SHA512.file(@path).hexdigest; end

    #
    # Determines the MIME type of the attachment.
    #
    # @return [String]
    #   The MIME type of the attachment file.
    #
    def mime_type
      Magic.guess_file_mime(@path)
    end

    #
    # Determines the encoding of the attachment.
    #
    # @return [String]
    #   The encoding of the attachment file.
    #
    def encoding
      Magic.guess_file_mime_encoding(@path)
    end

    #
    # Runs the attachment through ClamAV.
    #
    # @return [String]
    #   ClamAV signature for the attachment.
    #
    # @todo Implement.
    #
    def clamav
      raise(NotImplemented,"#{self.class}#clamav not implemented")
    end

    alias name to_s

    #
    # Converts the attachment metadata to a Hash.
    #
    # @return [Hash{String => String}]
    #   The attachment metadata.
    #
    def to_hash
      {
        'md5'    => md5,
        'sha1'   => sha1,
        'sha256' => sha256,
        'sha512' => sha512,

        'mime_type' => mime_type,
        'encoding'  => encoding
      }
    end

  end
end
