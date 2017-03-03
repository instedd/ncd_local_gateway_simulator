class Lgwsim::Simulator
  def initialize
    @config = Config.load
    @state = State.load
    @mutex = Mutex.new
    @client = QSTClient.new(
      host: @config.host,
      port: @config.port,
      account: @config.account,
      channel_name: @config.channel_name,
      channel_password: @config.channel_password)
  end

  def run
    loop do
      # Get last id successfully received by the server
      @state.last_at_id = @client.get_last_message_id

      messages = get_incoming_messages
      process_messages messages

      unless messages.empty?
        @state.last_ao_id = messages.last.id
        @state.save
      end

      send_outgoing_messages

      if messages.empty?
        sleep @config.sleep_seconds
      end
    end
  end

  private def get_incoming_messages
    puts "Fetching messages, etag: #{@state.last_ao_id}"
    messages = @client.pull(@state.last_ao_id)
    puts "Got #{messages.size} incoming messages"
    messages
  end

  private def process_messages(messages)
    # Generate fake reply for each of them
    messages.each do |msg|
      process_message msg
    end
  end

  private def process_message(msg)
    return if no_reply?

    body = if incorrect_reply?
             "(incorrect)"
           else
             msg.body.split(",").sample
           end

    reply = Message.new(
      id: `uuidgen`.chomp.downcase,
      from: msg.to,
      to: msg.from,
      body: body)

    if delay_reply?
      spawn do
        sleep delay_reply_seconds
        add_to_replies(reply)
      end
    else
      add_to_replies(reply)
    end
  end

  private def send_outgoing_messages
    return if @state.messages.empty?

    @mutex.synchronize do
      puts "Sending #{@state.messages.size} outgoing messages"
      etag = @client.push(@state.messages)
      @state.last_at_id = etag
      @state.save
    end
  end

  private def add_to_replies(reply)
    @mutex.synchronize do
      @state.messages << reply
    end
  end

  private def no_reply?
    @config.no_reply_percent >= rand
  end

  private def incorrect_reply?
    @config.incorrect_reply_percent >= rand
  end

  private def delay_reply?
    @config.delay_reply_percent >= rand
  end

  private def delay_reply_seconds
    rand(0.0..@config.delay_reply_max_seconds.to_f)
  end
end
