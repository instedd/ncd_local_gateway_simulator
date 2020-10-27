require "yaml"

class Lgwsim::Config
  FILENAME = "config.yml"

  YAML.mapping(
    host: String,
    port: Int32,
    tls: Bool,
    account: String,
    channel_name: String,
    channel_password: String,
    sleep_seconds: Int32,
    no_reply_percent: Float64,
    delay_reply_percent: Float64,
    delay_reply_min_seconds: Int32,
    delay_reply_max_seconds: Int32,
    incorrect_reply_percent: Float64,
    sticky_respondents: Bool,
  )

  def initialize
    @host = Config.string_env("HOST")
    @port = Config.int_env("PORT")
    @tls = Config.string_env("TLS") == "true"
    @account = Config.string_env("ACCOUNT")
    @channel_name = Config.string_env("CHANNEL_NAME")
    @channel_password = Config.string_env("CHANNEL_PASSWORD")
    @sleep_seconds = Config.int_env("SLEEP_SECONDS")
    @no_reply_percent = Config.float_env("NO_REPLY_PERCENT")
    @delay_reply_percent = Config.float_env("DELAY_REPLY_PERCENT")
    @delay_reply_min_seconds = Config.int_env("DELAY_REPLY_MIN_SECONDS")
    @delay_reply_max_seconds = Config.int_env("DELAY_REPLY_MAX_SECONDS")
    @incorrect_reply_percent = Config.float_env("INCORRECT_REPLY_PERCENT")
    @sticky_respondents = Config.string_env("STICKY_RESPONDENTS") == "true"
  end

  protected def self.string_env(var_name)
    unless (value = ENV[var_name]) && value != "***"
      raise "Missing #{var_name}"
    end
    value
  end

  protected def self.int_env(var_name)
    value = string_env(var_name)
    value.to_i rescue raise "#{var_name} must be an integer"
  end

  protected def self.float_env(var_name)
    value = string_env(var_name)
    value.to_f rescue raise "#{var_name} must be a float"
  end

  def self.load
    if File.exists?(FILENAME)
      Config.from_yaml(File.read(FILENAME))
    else
      # Try to load configuration from environment variables
      Config.new
    end
  end
end
