import Config

config :warlock,
  auth_challenge: "bearer",
  auth_error: "invalid_credentials",
  auth_realm: "warlock",
  items_per_page: "20",
  port: 8000,
  primary_key_type: :binary_id,
  response_type: :json,
  messages: [
    accepted: "accepted",
    bad_request: "bad request",
    unauthorized: "unauthorized",
    forbidden: "forbidden",
    not_found: "not found",
    not_allowed: "not allowed",
    conflict: "conflict",
    unsupported: "unsupported",
    unprocessable: "unprocessable",
    internal_error: "unknown",
    not_implemented: "not implemented"
  ]
