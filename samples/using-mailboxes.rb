require 'mailgun'

Mailgun::init("key-afy6amxoo2fnj$u@mc")

# creating a mailbox
mailbox = Mailbox.new(:user => 'new1', :domain => 'samples.mailgun.org', :password => '123123')
mailbox.upsert()
mailbox.password = '123456'
mailbox.upsert()

#upsert from csv
Mailbox.upsert_from_csv('up1@samples.mailgun.org, abc123\nup2@samples.mailgun.org, 321bca')

# print out all mailboxes
puts "Mailboxes:"
Mailbox.find(:all).each {|m| puts m.user + "@" + m.domain + " " + m.size}

