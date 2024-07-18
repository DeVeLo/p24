# frozen_string_literal: true

module P24
  module Api
    module V1
      module Request
        class TransactionRegister
          attr_reader :merchant_id, :pos_id, :session_id, :amount, :currency, :description, :email,
                      :client, :address, :zip, :city, :country, :phone, :language, :method, :url_return,
                      :url_status, :time_limit, :channel, :wait_for_result, :regulation_accept, :shipping,
                      :transfer_label, :mobile_lib, :sdk_version, :encoding, :method_ref_id, :crc

          def initialize(merchant_id:, pos_id:, session_id:, amount:, currency:, description:, email:,
                         country:, language:, url_return:, crc:, client: nil, address: nil, zip: nil, city: nil,
                         phone: nil, method: nil, url_status: nil, time_limit: nil, channel: nil,
                         wait_for_result: nil, regulation_accept: nil, shipping: nil, transfer_label: nil,
                         mobile_lib: nil, sdk_version: nil, encoding: nil, method_ref_id: nil)
            @merchant_id = merchant_id
            @pos_id = pos_id
            @session_id = session_id
            @amount = amount
            @currency = currency
            @description = description
            @email = email
            @client = client
            @address = address
            @zip = zip
            @city = city
            @country = country
            @phone = phone
            @language = language
            @method = method
            @url_return = url_return
            @url_status = url_status
            @time_limit = time_limit
            @channel = channel
            @wait_for_result = wait_for_result
            @regulation_accept = regulation_accept
            @shipping = shipping
            @transfer_label = transfer_label
            @mobile_lib = mobile_lib
            @sdk_version = sdk_version
            @encoding = encoding
            @method_ref_id = method_ref_id
            @crc = crc
          end

          def to_json(*_args)
            {
              merchantId: merchant_id,
              posId: pos_id,
              sessionId: session_id,
              amount:,
              currency:,
              description:,
              email:,
              client:,
              address:,
              zip:,
              city:,
              country:,
              phone:,
              language:,
              method:,
              urlReturn: url_return,
              urlStatus: url_status,
              timeLimit: time_limit,
              channel:,
              waitForResult: wait_for_result,
              regulationAccept: regulation_accept,
              shipping:,
              transferLabel: transfer_label,
              mobileLib: mobile_lib,
              sdkVersion: sdk_version,
              sign:,
              encoding:,
              methodRefId: method_ref_id
            }.compact.to_json
          end

          private

          def sign_params
            {
              sessionId: session_id,
              merchantId: merchant_id,
              amount:,
              currency:,
              crc:
            }
          end

          def sign
            Digest::SHA384.hexdigest sign_params.to_json
          end
        end
      end
    end
  end
end
