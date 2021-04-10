import Config

config :warlock,
  auth_challenge: "bearer",
  auth_error: "invalid_credentials",
  auth_realm: "warlock",
  items_per_page: "20",
  port: 8000,
  primary_key_type: :binary_id,
  response_type: :json
