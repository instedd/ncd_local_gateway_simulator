require "json"

class Lgwsim::State
  FILENAME = "state.json"

  JSON.mapping(
    last_at_id: {type: String?, setter: false},
    last_ao_id: String?,
    messages: Array(Message),
  )

  def initialize
    @etag = nil
    @messages = [] of Message
  end

  def last_at_id=(etag : String?)
    @etag = etag
    if etag
      index = self.messages.index { |m| m.id == etag }
      if index
        self.messages = self.messages[index + 1..-1]
      end
    end
    save
  end

  def self.load
    if File.exists?(FILENAME)
      from_json(File.read(FILENAME))
    else
      new
    end
  end

  def save
    File.write(FILENAME, to_pretty_json)
  end
end
