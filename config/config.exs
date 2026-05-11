import Config

config :logger, :console,
  format: "[$level] $message\n"

if Mix.env() == :test do
  config :logger, level: :warning
end
