require "json"
require "json_mapping"
require "xml"

record Lgwsim::Message,
  id : String,
  from : String,
  to : String,
  body : String do
  JSON.mapping(
    id: String,
    from: String,
    to: String,
    body: String,
  )

  def self.many_from_xml(string)
    doc = XML.parse(string)
    messages = doc.first_element_child.not_nil!
    messages.children.select(&.element?).map do |message|
      Message.new(
        id: message["id"],
        from: message["from"],
        to: message["to"],
        body: message.children.find { |c| c.element? && c.name == "text" }.not_nil!.text
      )
    end
  end

  def self.many_to_xml(messages)
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
end
