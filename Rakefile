require 'rubygems'

begin
  require 'bundler/setup'
rescue LoadError => e
  warn e.message
  warn "Run `gem install bundler` to install Bundler"
  exit -1
end

$LOAD_PATH.unshift(File.expand_path('lib'))

require 'email/message'
require 'email/attachment'

require 'mechanize'

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
      chdir File.basename(category) do
        sh 'zip', '-r', '-P', 'infected', File.basename(zipfile), File.basename(message_dir)
      end
    end

    desc "Creates zip archives of all emails"
    task :zip => zipfile
  end
end
