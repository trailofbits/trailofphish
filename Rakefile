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

namespace :emails do
  INPUT_DIR  = File.join('data','raw')
  OUTPUT_DIR = File.join('data','processed')

  Dir.glob("#{INPUT_DIR}/*") do |input_category_dir|
    output_category_dir = File.join(OUTPUT_DIR,File.basename(input_category_dir))

    Dir.glob("#{input_category_dir}/*.eml") do |input_email|
      output_email_dir  = File.join(output_category_dir,Email::Message.md5(input_email))
      output_email_path = File.join(output_email_dir,'message.eml')

      directory output_email_dir

      file output_email_path => output_email_dir do
        email = Email::Message.new(input_email)

        puts ">>> Anonymizing #{input_email} ..."

        File.open(output_email_path,'w') do |output_file|
          output_file.write(email.anonymize)
        end
      end

      desc "Anonymizes all original emails"
      task :anonymize => output_email_path

      links_dir = File.join(output_email_dir,'links')

      file links_dir => output_email_dir do
        email = Email::Message.new(input_email)

        browser = Mechanize.new
        browser.pluggable_parser.default = Mechanize::Download

        mkdir links_dir

        email.links.each do |url|
          uri = URI(url)

          output = File.join(links_dir,uri.host,uri.request_uri)
          mkdir_p File.dirname(output)

          puts ">>> Downloading #{url} ..."
          browser.get(url).save(output)
        end
      end

      desc 'Extracts all links from all emails'
      task 'extract:links' => links_dir

      attachments_dir = File.join(output_email_dir,'attachments')

      file attachments_dir => output_email_dir do
        email = Email::Message.new(input_email)

        mkdir attachments_dir

        email.attachments.each do |attachment|
          puts ">>> Extracting attachment #{attachment.filename} ..."

          File.open(File.join(attachments_dir,attachment.filename),'wb') do |file|
            file.write attachment.body.to_s
          end
        end
      end

      desc "Extracts all attachments from all emails"
      task 'extract:attachments' => attachments_dir

      zip_path = "#{output_email_dir}.zip"

      task zip_path => [output_email_path, links_dir, attachments_dir] do
        chdir output_category_dir do
          sh 'zip', '-r', '-P', 'infected', File.basename(zip_path),
                                            File.basename(output_email_dir)
        end
      end

      desc "Creates zip archives of all emails"
      task :zip => zip_path
    end
  end
end

require 'yard'
YARD::Rake::YardocTask.new  
