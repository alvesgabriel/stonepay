defmodule Stonepay.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :stonepay,
    error_handler: Stonepay.Auth.ErrorHandler,
    module: Stonepay.Auth.Guardian

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, allow_blank: true
end
