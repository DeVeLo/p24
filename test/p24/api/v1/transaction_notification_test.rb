# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestTransactionNotification < Minitest::Test
  def setup
    @merchant_id = 12_345
    @pos_id = 67_890
    @session_id = 'test_session_123'
    @amount = 10_000
    @origin_amount = 9500
    @currency = 'PLN'
    @order_id = 999
    @method_id = 25
    @statement = 'Test payment'
    @crc = 'test_crc_value'
    @sign = 'test_sign_value'
  end

  def test_initialization_with_all_parameters
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc,
      sign: @sign
    )

    assert_equal @merchant_id, notification.merchant_id
    assert_equal @pos_id, notification.pos_id
    assert_equal @session_id, notification.session_id
    assert_equal @amount, notification.amount
    assert_equal @origin_amount, notification.origin_amount
    assert_equal @currency, notification.currency
    assert_equal @order_id, notification.order_id
    assert_equal @method_id, notification.method_id
    assert_equal @statement, notification.statement
    assert_equal @crc, notification.crc
    assert_equal @sign, notification.sign
  end

  def test_initialization_without_sign
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc
    )

    assert_nil notification.sign
  end

  def test_to_json_includes_all_fields
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc,
      sign: @sign
    )

    json = JSON.parse(notification.to_json)

    assert_equal @merchant_id, json['merchantId']
    assert_equal @pos_id, json['posId']
    assert_equal @session_id, json['sessionId']
    assert_equal @amount, json['amount']
    assert_equal @origin_amount, json['originAmount']
    assert_equal @currency, json['currency']
    assert_equal @order_id, json['orderId']
    assert_equal @method_id, json['methodId']
    assert_equal @statement, json['statement']
    assert_equal @sign, json['sign']
  end

  def test_to_json_excludes_nil_sign
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc
    )

    json = JSON.parse(notification.to_json)

    refute json.key?('sign')
  end

  def test_to_json_returns_valid_json_string
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc,
      sign: @sign
    )

    json_string = notification.to_json

    assert_instance_of String, json_string

    parsed = JSON.parse(json_string)
    assert_instance_of Hash, parsed
  end

  def test_correct_returns_true_for_valid_sign
    sign_params = {
      merchantId: @merchant_id,
      posId: @pos_id,
      sessionId: @session_id,
      amount: @amount,
      originAmount: @origin_amount,
      currency: @currency,
      orderId: @order_id,
      methodId: @method_id,
      statement: @statement,
      crc: @crc
    }
    valid_sign = Digest::SHA384.hexdigest(sign_params.to_json)

    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc,
      sign: valid_sign
    )

    assert notification.correct?
  end

  def test_correct_returns_false_for_invalid_sign
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc,
      sign: 'invalid_sign'
    )

    refute notification.correct?
  end

  def test_correct_returns_false_for_nil_sign
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id,
      pos_id: @pos_id,
      session_id: @session_id,
      amount: @amount,
      origin_amount: @origin_amount,
      currency: @currency,
      order_id: @order_id,
      method_id: @method_id,
      statement: @statement,
      crc: @crc
    )

    refute notification.correct?
  end

  def test_handles_string_amount_values
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: @merchant_id.to_s,
      pos_id: @pos_id.to_s,
      session_id: @session_id,
      amount: @amount.to_s,
      origin_amount: @origin_amount.to_s,
      currency: @currency,
      order_id: @order_id.to_s,
      method_id: @method_id.to_s,
      statement: @statement,
      crc: @crc,
      sign: @sign
    )

    assert_equal @merchant_id.to_s, notification.merchant_id
    assert_equal @amount.to_s, notification.amount
    assert_equal @origin_amount.to_s, notification.origin_amount
  end

  def test_handles_nil_values
    notification = P24::Api::V1::TransactionNotification.new(
      merchant_id: nil,
      pos_id: nil,
      session_id: nil,
      amount: nil,
      origin_amount: nil,
      currency: nil,
      order_id: nil,
      method_id: nil,
      statement: nil,
      crc: nil
    )

    assert_nil notification.merchant_id
    assert_nil notification.amount
    assert_nil notification.statement
  end
end
