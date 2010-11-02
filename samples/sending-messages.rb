require 'mailgun'

Mailgun::init("key-afy6amxoo2fnj$u@mc")

# Sending a simple text message:
MailgunMessage::send_text("me@samples.mailgun.org",
                  "you@yourhost, 'Him' <you@mailgun.info>",
                  "Hello",
                  "Hi!\nI am sending the message using Mailgun Ruby API")

# Sending a MIME message:
sender   = "me@samples.mailgun.org"
receiver = "you@mailgun.info"
raw_mime =
  "Content-Type: text/plain;charset=utf-8\n" +
  "From: #{sender}\n" +
  "To: #{receiver}\n" +
  "Content-Type: text/plain;charset=utf-8\n" +
  "Subject: Hello!\n" +
  "\n" +
  "Sending the message using Mailgun Ruby API"
MailgunMessage::send_raw(sender, receiver, raw_mime)

puts "Messages sent"
