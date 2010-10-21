require 'mailgun'

Mailgun::init("my-api-key")

# creating a route:
route = Route.new(:pattern => '*@myhost.com', :destination => 'http://myhost.com/post')
route.upsert()

# print out all routes:
puts "Routes:"
Route.find(:all).each {|r| puts r.pattern + "\t==> " + r.destination}
