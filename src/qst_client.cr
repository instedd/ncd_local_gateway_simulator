require "http/client"
require "xml"

class Lgwsim::QSTClient
  class Error < Exception; end

  def initialize(
                 host = "nuntium-stg.instedd.org",
                 port = 80,
                 tls = false,
                 *,
                 account : String,
                 channel_name : String,
                 channel_password : String)
    @account = URI.escape(account)
    @client = HTTP::Client.new(host: host, port: port, tls: tls)
    @client.basic_auth(channel_name, channel_password)
  end

  def get_last_message_id
    response = @client.head("/#{@account}/qst/outgoing")
    check_response(response, "get_last_message_id")
    fetch_etag(response)
  end

  def push(*, id : String, from : String, to : String, body : String)
    push(Message.new(id, from, to, body))
  end

  def push(message : Message)
    push([message])
  end

  def push(messages : Array(Message))
    return if messages.empty?

    xml = to_xml(messages)
    response = @client.post("/#{@account}/qst/incoming.xml",
      body: xml,
      headers: HTTP::Headers{"Content-Type" => "text/xml"})
    check_response(response, "push")
    fetch_etag(response)
  end

  def pull(etag = nil)
    headers = HTTP::Headers.new
    headers["If-None-Match"] = etag if etag

    response = @client.get("/#{@account}/qst/outgoing.xml?max=100", headers: headers)

    # Check Not-Modified
    if response.status_code == 304
      return [] of Message
    end

    check_response(response, "pull")
    from_xml(response)
  end

  private def to_xml(messages)
    XML.build(indent: 2) do |xml|
      xml.element("messages") do
        messages.each do |msg|
          xml.element("message", id: msg.id, from: msg.from, to: msg.to) do
            xml.element("text") do
              xml.text msg.body
            end
          end
        end
      end
    end
  end

  private def from_xml(response)
    doc = XML.parse(response.body)
    messages = doc.first_element_child.not_nil!
    messages.children.select(&.element?).map do |message|
      Message.new(
        id: message["id"].not_nil!,
        from: message["from"].not_nil!,
        to: message["to"].not_nil!,
        body: message.children.find { |c| c.element? && c.name == "text" }.not_nil!.text.not_nil!
      )
    end
  end

  private def fetch_etag(response)
    etag = response.headers["Etag"]?
    return nil unless etag

    etag.empty? ? nil : etag
  end

  private def check_response(response, msg)
    unless response.success?
      response.to_io(STDOUT)
      raise Error.new("Got #{response.status_code} in #{msg}")
    end
  end
end
