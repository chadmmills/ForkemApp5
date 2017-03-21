Clearance.configure do |config|
  config.routes = false
  config.mailer_sender = "reply@forkit.io"
  config.rotate_csrf_on_sign_in = true
end
