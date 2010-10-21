require 'mailgun'

Mailgun::init("my-api-key")

# Sending a simple text message:
MailgunMessage::send_text("me@myhost",
                  "you@yourhost, 'Him' <him@hishost>",
                  "Hello",
                  "Hi!\nI am sending the message using Mailgun")

# Sending a MIME message:
sender   = "me@myhost"
receiver = "you@yourhost"
raw_mime =
  "Content-Type: text/plain;charset=utf-8\n" +
  "From: #{sender}\n" +
  "To: #{receiver}\n" +
  "Content-Type: text/plain;charset=utf-8\n" +
  "Subject: Hello!\n" +
  "\n" +
  "This is message body"
MailgunMessage::send_raw(sender, receiver, raw_mime)

puts "Messages sent"