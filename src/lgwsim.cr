require "./*"

config = Config.load
state = State.load

client = QSTClient.new(
  host: config.host,
  port: config.port,
  account: config.account,
  channel_name: config.channel_name,
  channel_password: config.channel_password)

loop do
  # Get last id successfully received by the server
  state.last_at_id = client.get_last_message_id

  # Get incoming messages
  puts "Fetching messages, etag: #{state.last_ao_id}"
  messages = client.pull(state.last_ao_id)
  puts "Got #{messages.size} incoming messages"

  # Generate fake reply for each of them
  messages.each do |msg|
    options = msg.body.split(",")
    option = options.sample
    reply = Message.new(
      id: `uuidgen`.chomp.downcase,
      from: msg.to,
      to: msg.from,
      body: option)
    state.messages << reply
  end

  unless messages.empty?
    state.last_ao_id = messages.last.id
    state.save
  end

  # Send outgoing messages
  unless state.messages.empty?
    puts "Sending #{state.messages.size} outgoing messages"
    etag = client.push(state.messages)
    state.last_at_id = etag
    state.save
  end

  if messages.empty?
    sleep config.sleep_seconds
  end
end
