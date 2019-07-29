# General application configuration
import Config

config :consul_config_provider, :http_module, Client.Mojito

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
