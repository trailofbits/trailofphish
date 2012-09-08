require 'digest/md5'
require 'digest/sha1'
require 'digest/sha2'
# require 'ssdeep'
require 'magic'

module Email
  class Attachment

    attr_reader :path, :name

    def initialize(path)
      @path = path
      @name = File.basename(path)
    end

    def md5;    Digest::MD5.file(@path).hexdigest;    end
    def sha1;   Digest::SHA1.file(@path).hexdigest;   end
    def sha256; Digest::SHA256.file(@path).hexdigest; end
    def sha512; Digest::SHA512.file(@path).hexdigest; end

    def mime_type
      Magic.guess_file_mime(@path)
    end

    def encoding
      Magic.guess_file_mime_encoding(@path)
    end

    alias name to_s

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
