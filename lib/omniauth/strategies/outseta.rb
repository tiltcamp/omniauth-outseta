# frozen_string_literal: true

require "jwt"
require "omniauth"
require "openssl"

module OmniAuth
  module Strategies
    class Outseta
      include OmniAuth::Strategy

      args [:subdomain, :jwt_public_key]

      def request_phase
        redirect "https://#{options.subdomain}.outseta.com/auth?authenticationCallbackUrl=#{CGI.escape(callback_url)}"
      end

      uid { raw_info[:sub] }

      info do
        {
          name: raw_info[:name],
          email: raw_info[:email],
          first_name: raw_info[:given_name],
          last_name: raw_info[:family_name]
        }
      end

      credentials do
        {
          token: access_token,
          expires: true,
          expires_at: raw_info[:exp]
        }
      end

      extra do
        {
          raw_info: raw_info,
          account_uid: raw_info[:"outseta:accountUid"],
          is_primary: raw_info[:"outseta:isPrimary"] == "1",
          subscription_uid: raw_info[:"outseta:subscriptionUid"],
          plan_uid: raw_info[:"outseta:planUid"],
          addon_uids: raw_info[:"outseta:addonUids"]
        }
      end

      private

      def jwt_public_key
        @jwt_public_key ||= OpenSSL::X509::Certificate.new(options.jwt_public_key).public_key
      end

      def access_token
        @access_token ||= request.params["access_token"]
      end

      def raw_info
        @raw_info ||= ::JWT.decode(access_token, jwt_public_key, true, {algorithm: "RS256"})[0].deep_symbolize_keys
      end
    end
  end
end
