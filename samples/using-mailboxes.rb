require 'mailgun'

Mailgun::init("my-api-key")

# creating a mailbox
mailbox = Mailbox.new(:user => 'new1', :domain => 'myhost.com', :password => '123123')
mailbox.upsert()
mailbox.password = '123456'
mailbox.upsert()

#upsert from csv
Mailbox.upsert_from_csv('up1@myhost.com, abc123\nup2@myhost.com, 321bca')

# print out all mailboxes
puts "Mailboxes:"
Mailbox.find(:all).each {|m| puts m.user + "@" + m.domain + " " + m.size}

