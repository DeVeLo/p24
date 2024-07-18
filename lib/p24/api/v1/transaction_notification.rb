# frozen_string_literal: true

module P24
  class TransactionNotification
    attr_reader :merchant_id, :pos_id, :session_id, :amount, :origin_amount, :currency,
                :order_id, :method_id, :statement, :crc, :sign

    def initialize(merchant_id:, pos_id:, session_id:, amount:, currency:, order_id:, crc:, sign: nil)
      @merchant_id = merchant_id
      @pos_id = pos_id
      @session_id = session_id
      @amount = amount
      @origin_amount = origin_amount
      @currency = currency
      @order_id = order_id
      @method_id = method_id
      @statement = statement
      @sign = sign
      @crc = crc
    end

    def to_json(*_args)
      {
        merchantId: merchant_id,
        posId: pos_id,
        sessionId: session_id,
        amount:,
        originAmount: origin_amount,
        currency:,
        orderId: order_id,
        methodId: method_id,
        statement:,
        sign:
      }.compact.to_json
    end

    def from_json(json, crc)
      new(
        merchant_id: json['merchantId'],
        pos_id: json['posId'],
        session_id: json['sessionId'],
        amount: ['amount'],
        origin_amount: json['originAmount'],
        currency: json['currency'],
        order_id: json['orderId'],
        method_id: json['methodId'],
        statement: json['statement'],
        sign: json['sign'],
        crc:
      )
    end

    def correct?
      sign == Digest::SHA384.hexdigest(sign_params.to_json)
    end

    private

    def sign_params
      {
        merchantId: merchant_id,
        posId: pos_id,
        sessionId: session_id,
        amount:,
        originAmount: origin_amount,
        currency:,
        orderId: order_id,
        methodId: method_id,
        statement:,
        crc:
      }
    end
  end
end
