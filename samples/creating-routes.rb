require 'mailgun'

Mailgun::init("key-afy6amxoo2fnj$u@mc")

# creating a route:
route = Route.new(:pattern => '*@samples.mailgun.org', :destination => 'http://samples.mailgun.org/post')
route.upsert()

# print out all routes:
puts "Routes:"
Route.find(:all).each {|r| puts r.pattern + "\t==> " + r.destination}
