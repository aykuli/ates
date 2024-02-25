# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include UsersHelper

    EVENT_NAME = 'user.created'

    # rubocop:disable Metrics/AbcSize
    def create
      build_resource(registration_params)

      if resource.save
        users_producer.produce_async(EVENT_NAME, event)

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_navigational_format?
          sign_up(resource_name, resource)
        elsif is_navigational_format?
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        end
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        clean_up_passwords
        respond_with resource
      end
    end
    # rubocop:enable Metrics/AbcSize

    private

    def registration_params
      params.require(:user).permit(:email, :admin, :password, :password_confirmation)
    end
  end
end
