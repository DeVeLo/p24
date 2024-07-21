# frozen_string_literal: true

module P24
  module Api
    module V1
      module Request
        class TransactionVerify
          attr_reader :merchant_id, :pos_id, :session_id, :amount, :currency, :order_id, :crc

          def initialize(merchant_id:, pos_id:, session_id:, amount:, currency:, order_id:, crc:)
            @merchant_id = merchant_id
            @pos_id = pos_id
            @session_id = session_id
            @amount = amount
            @currency = currency
            @order_id = order_id
            @crc = crc
          end

          def to_json(*_args)
            {
              merchantId: merchant_id,
              posId: pos_id,
              orderId: order_id,
              sessionId: session_id,
              amount:,
              currency:,
              sign:
            }.compact.to_json
          end

          private

          def sign_params
            {
              sessionId: session_id,
              orderId: order_id,
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
