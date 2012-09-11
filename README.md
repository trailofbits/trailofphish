# Trail of Phish

Trail of Phish is a private repository of phishing emails.

## Usage

Original email messages are stored in `data/raw/`, and a [Rakefile] is used to
generate the anonymized email messages, archive links, extract attachments and
create zip archives of the emails.

## Directory Structure

* `data/raw` - Contains the raw and unanonymized emails, grouped into category
  directories, such as `crime` and `phishing`.
* `data/processed` - Contains the anonymized emails and additional metadata,
  grouped into category directories, such as `crime` and `phishing`.
* `data/processed/$md5/message.eml` - The anonymized email message.
* `data/processed/$md5/links/` - The archive of every link contained
  within the email body.
* `data/processed/$md5/attachments/` - Contains the extracted attachments
  contained within the email.
* `data/processed/$md5.zip` - A password protected (`infected`) zip archive
  of the anonymized email, archive links and extracted attachments.

## Rake Tasks

* `rake emails:anonymize` - Anonymizes all original emails.
* `rake emails:extract:attachments` - Extracts all attachments from all emails.
* `rake emails:extract:links` - Extracts all links from all emails.
* `rake emails:zip` - Creates zip archives of all emails.
* `rake yard` - Generate API Documentation in the `doc/` directory.

## Anonymization

All emails are anonymized by having the following data replaced with an equal
number of `X` characters:

* Email addresses listed in the `To` header.
* Display names listed in the `To` header.

[Rakefile]: http://en.wikipedia.org/wiki/Rake_%28software%29
