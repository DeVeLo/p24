# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'digest'

class TestTransactionVerify < Minitest::Test
  def setup
    @required_params = {
      merchant_id: 123_456,
      pos_id: 123_456,
      session_id: 'test_session_123',
      amount: 10_000,
      currency: 'PLN',
      order_id: 'order_123',
      crc: 'test_crc_key'
    }
  end

  def test_initialization_with_required_params
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)

    assert_equal 123_456, transaction.merchant_id
    assert_equal 123_456, transaction.pos_id
    assert_equal 'test_session_123', transaction.session_id
    assert_equal 10_000, transaction.amount
    assert_equal 'PLN', transaction.currency
    assert_equal 'order_123', transaction.order_id
    assert_equal 'test_crc_key', transaction.crc
  end

  def test_to_json_converts_to_camel_case
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    assert json.key?('merchantId')
    assert json.key?('posId')
    assert json.key?('sessionId')
    assert json.key?('orderId')
    refute json.key?('merchant_id')
    refute json.key?('pos_id')
    refute json.key?('session_id')
    refute json.key?('order_id')
  end

  def test_to_json_includes_all_required_fields
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    assert_equal 123_456, json['merchantId']
    assert_equal 123_456, json['posId']
    assert_equal 'test_session_123', json['sessionId']
    assert_equal 10_000, json['amount']
    assert_equal 'PLN', json['currency']
    assert_equal 'order_123', json['orderId']
    assert json.key?('sign')
  end

  def test_to_json_excludes_crc_field
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    refute json.key?('crc')
  end

  def test_sign_generates_sha384_hash
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)
    json = JSON.parse(transaction.to_json)
    sign = json['sign']

    assert_equal 96, sign.length
    assert_match(/\A[a-f0-9]{96}\z/, sign)
  end

  def test_sign_is_deterministic
    transaction1 = P24::Api::V1::Request::TransactionVerify.new(**@required_params)
    transaction2 = P24::Api::V1::Request::TransactionVerify.new(**@required_params)

    json1 = JSON.parse(transaction1.to_json)
    json2 = JSON.parse(transaction2.to_json)

    assert_equal json1['sign'], json2['sign']
  end

  def test_sign_changes_with_different_params
    transaction1 = P24::Api::V1::Request::TransactionVerify.new(**@required_params)

    different_params = @required_params.merge(amount: 20_000)
    transaction2 = P24::Api::V1::Request::TransactionVerify.new(**different_params)

    json1 = JSON.parse(transaction1.to_json)
    json2 = JSON.parse(transaction2.to_json)

    refute_equal json1['sign'], json2['sign']
  end

  def test_sign_based_on_specific_params
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)

    expected_sign_params = {
      sessionId: 'test_session_123',
      orderId: 'order_123',
      amount: 10_000,
      currency: 'PLN',
      crc: 'test_crc_key'
    }
    expected_sign = Digest::SHA384.hexdigest(expected_sign_params.to_json)

    json = JSON.parse(transaction.to_json)
    assert_equal expected_sign, json['sign']
  end

  def test_to_json_returns_valid_json_string
    transaction = P24::Api::V1::Request::TransactionVerify.new(**@required_params)
    json_string = transaction.to_json

    assert_instance_of String, json_string

    json = JSON.parse(json_string)
    assert_instance_of Hash, json
    assert json.key?('sign')
    assert json.key?('merchantId')
    assert json.key?('posId')
    assert json.key?('sessionId')
    assert json.key?('orderId')
    assert json.key?('amount')
    assert json.key?('currency')
  end
end
