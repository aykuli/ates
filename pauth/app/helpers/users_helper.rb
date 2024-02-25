# frozen_string_literal: true

module UsersHelper
  private

  # @param params [ActionController::Parameters]
  # @return       [Hash]
  def build_attributes(params)
    new_email = params[:email]
    role      = params[:role]

    {
      email: new_email.empty? ? nil : new_email,
      admin: role == 'admin'
    }.compact
  end
end
