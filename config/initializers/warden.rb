Rails.configuration.middleware.use RailsWarden::Manager do |manager|
  manager.default_strategies :password

  manager.failure_app = lambda { |env|
    SessionsController.action(:new).call(env)
  }
end

# Setup Session Serialization
class Warden::SessionSerializer
  def serialize(account)
    account.id
  end

  def deserialize(id)
    account = Account.find_by_id(id)

    request = Rack::Request.new(env)

    if account.sites.include? request.host
      return account
    else
      return nil
    end
  end
end

# Strategies
Warden::Strategies.add(:password) do
  def authenticate!
    email = params['account']['email']
    password = params['account']['password']

    if account = Account.find_and_authenticate(email, password, request.host)
      success! account
    else
      fail! 'sessions.new.flash.invalid_login'
    end
  end
end
