require 'rubygems'
require 'active_resource'

class Mailgun

  # Initializes Mailgun API
  # Must be called before any other method
  #
  # Parameters:
  #   api_key - Your API key
  #   api_url - API base URL
  #
  def self.init(api_key, api_url = "http://mailgun.net/api/")
    MailgunResource.password = api_key
    api_url = api_url.gsub(/\/$/, '') + "/"
    MailgunResource.site = api_url
  end

  # This is a patch of private ActiveResource method.
  # It takes HTTPResponse and raise AR-like error if response code is not 2xx
  def self.handle_response(response)
    case response.code.to_i
      when 301,302
        raise(Redirection.new(response))
      when 200...400
        response
      when 400
        raise(ActiveResource::BadRequest.new(response))
      when 401
        raise(ActiveResource::UnauthorizedAccess.new(response))
      when 403
        raise(ActiveResource::ForbiddenAccess.new(response))
      when 404
        raise(ActiveResource::ResourceNotFound.new(response))
      when 405
        raise(ActiveResource::MethodNotAllowed.new(response))
      when 409
        raise(ActiveResource::ResourceConflict.new(response))
      when 410
        raise(ActiveResource::ResourceGone.new(response))
      when 422
        raise(ActiveResource::ResourceInvalid.new(response))
      when 401...500
        raise(ActiveResource::ClientError.new(response))
      when 500...600
        raise(ActiveResource::ServerError.new(response))
      else
        raise(ConnectionError.new(response, "Unknown response code: #{response.code}"))
    end
  end

end


class MailgunMessage
  # Sends a MIME-formatted message
  #
  #  raw_mime =
  #    "Content-Type: text/plain;charset=utf-8\n" +
  #    "From: me@host\n" + 
  #    "To: you@host\n" + 
  #    "Subject: Hello!\n\n" +
  #    "Body"
  #  MailgunMessage::send_raw("me@host", "you@host", raw_mime)
  #
  def self.send_raw(sender, recipients, raw_body, servername='')
    uri_str = "#{MailgunResource.site}messages.eml?api_key=#{MailgunResource.password}&servername=#{servername}"
    uri = URI.parse(uri_str)
    data = "#{sender}\n#{recipients}\n\n#{raw_body}"
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path + "?" + uri.query, data, {"Content-type" => "text/plain" })
    Mailgun::handle_response(res)
  end

  # Sends a plain-text message
  #
  # MailgunMessage::send_text("me@host.com",
  #      "you@host.com",
  #      "Subject",
  #      "Hi!\nThis is message body")
  #
  def self.send_text(sender, recipients, subject, text, servername='')
    uri_str = "#{MailgunResource.site}messages.txt?api_key=#{MailgunResource.password}&servername=#{servername}"
    uri = URI.parse(uri_str)
    params = { :sender => sender, :recipients => recipients, :subject => subject, :body => text}
    req = Net::HTTP::Post.new(uri.path + "?" + uri.query)
    req.set_form_data(params)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.request(req)
    Mailgun::handle_response(res)
  end

end

# Base class for Mailgun resource classes
# It adds upsert() method on top of ActiveResource::Base
#
class MailgunResource < ActiveResource::Base
  self.user = "api_key"

  # Create new resource or update it if resource already exist.
  # There are 2 differences between upsert() and save():
  #   - Upsert does not raise an exception if a resource already exist.
  #   - Upsert does not return the id of freshly inserted resource
  #
  #  >> route = Route.new
  #  >> route.pattern = '*@mydomain.com'
  #  >> route.destination = 'http://mydomain.com/addcomment'
  #  >> route.upsert()
  #
  def upsert()
    self.class.post('upsert', {}, self.to_xml())
  end
end



# All mail arriving to email addresses that have mailboxes associated
# will be stored on the server and can be later accessed via IMAP or POP3
# protocols.
#    
# Mailbox has several properties:
#
# alex@gmail.com
#  ^      ^
#  |      |
# user    domain
#
class Mailbox < MailgunResource
  # Example of a CSV file:
  #        
  # john@domain.com, password
  # doe@domain.com, password2         
  #
  def self.upsert_from_csv(mailboxes)
    uri_str = "#{MailgunResource.site}mailboxes.txt?api_key=#{MailgunResource.password}"
    uri = URI.parse(uri_str)
    http = Net::HTTP.new(uri.host, uri.port)
    res = http.post(uri.path + "?" + uri.query, mailboxes, {"Content-type" => "text/plain" })
    Mailgun::handle_response(res)
  end
end


# This class represents Mailgun route.
# A route has 2 properties: pattern and destination
#
# Examples of patterns:
#   - '*' - match all
#   - exact match (foo@bar.com)
#   - domain pattern, i.e. a pattern like "@example.com" - it will match all emails going to example.com
#   - any regular expression
#
# Destination can be one of:
#   - an email address to forward to 
#   - a URL for HTTP POST
class Route < MailgunResource
end
