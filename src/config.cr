require "yaml"

class Lgwsim::Config
  FILENAME = "config.yml"

  YAML.mapping(
    host: String,
    port: Int32,
    account: String,
    channel_name: String,
    channel_password: String,
    sleep_seconds: Int32,
    no_reply_percent: Float64,
    delay_reply_percent: Float64,
    delay_reply_max_seconds: Int32,
    incorrect_reply_percent: Float64,
  )

  def self.load
    if File.exists?(FILENAME)
      Config.from_yaml(File.read(FILENAME))
    else
      abort "Missing config.yml"
    end
  end
end
