# frozen_string_literal: true

Rails.application.configure do
  config.ioc = Dry::Container.new
  Aux::Pluggable.registry = config.ioc
end
