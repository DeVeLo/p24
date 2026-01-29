# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'digest'

class TestTransactionRegister < Minitest::Test
  def setup
    @required_params = {
      merchant_id: 123_456,
      pos_id: 123_456,
      session_id: 'test_session_123',
      amount: 10_000,
      currency: 'PLN',
      description: 'Test payment',
      email: 'test@example.com',
      country: 'PL',
      language: 'pl',
      url_return: 'https://example.com/return',
      crc: 'test_crc_key'
    }
  end

  def test_initialization_with_required_params
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)

    assert_equal 123_456, transaction.merchant_id
    assert_equal 123_456, transaction.pos_id
    assert_equal 'test_session_123', transaction.session_id
    assert_equal 10_000, transaction.amount
    assert_equal 'PLN', transaction.currency
    assert_equal 'Test payment', transaction.description
    assert_equal 'test@example.com', transaction.email
    assert_equal 'PL', transaction.country
    assert_equal 'pl', transaction.language
    assert_equal 'https://example.com/return', transaction.url_return
    assert_equal 'test_crc_key', transaction.crc
  end

  def test_initialization_with_optional_params
    params = @required_params.merge(
      client: 'Jan Kowalski',
      address: 'ul. Testowa 1',
      zip: '00-001',
      city: 'Warszawa',
      phone: '+48123456789',
      method: 25,
      url_status: 'https://example.com/status',
      time_limit: 15,
      channel: 1,
      wait_for_result: true,
      regulation_accept: true,
      shipping: 500,
      transfer_label: 'Test transfer',
      mobile_lib: true,
      sdk_version: '1.0',
      encoding: 'UTF-8',
      method_ref_id: 'ref_123'
    )

    transaction = P24::Api::V1::Request::TransactionRegister.new(**params)

    assert_equal 'Jan Kowalski', transaction.client
    assert_equal 'ul. Testowa 1', transaction.address
    assert_equal '00-001', transaction.zip
    assert_equal 'Warszawa', transaction.city
    assert_equal '+48123456789', transaction.phone
    assert_equal 25, transaction.method
    assert_equal 'https://example.com/status', transaction.url_status
    assert_equal 15, transaction.time_limit
    assert_equal 1, transaction.channel
    assert transaction.wait_for_result
    assert transaction.regulation_accept
    assert_equal 500, transaction.shipping
    assert_equal 'Test transfer', transaction.transfer_label
    assert transaction.mobile_lib
    assert_equal '1.0', transaction.sdk_version
    assert_equal 'UTF-8', transaction.encoding
    assert_equal 'ref_123', transaction.method_ref_id
  end

  def test_optional_params_default_to_nil
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)

    assert_nil transaction.client
    assert_nil transaction.address
    assert_nil transaction.zip
    assert_nil transaction.city
    assert_nil transaction.phone
    assert_nil transaction.method
    assert_nil transaction.url_status
    assert_nil transaction.time_limit
    assert_nil transaction.channel
    assert_nil transaction.wait_for_result
    assert_nil transaction.regulation_accept
    assert_nil transaction.shipping
    assert_nil transaction.transfer_label
    assert_nil transaction.mobile_lib
    assert_nil transaction.sdk_version
    assert_nil transaction.encoding
    assert_nil transaction.method_ref_id
  end

  def test_to_json_converts_to_camel_case
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    assert json.key?('merchantId')
    assert json.key?('posId')
    assert json.key?('sessionId')
    assert json.key?('urlReturn')
    refute json.key?('merchant_id')
    refute json.key?('pos_id')
    refute json.key?('session_id')
    refute json.key?('url_return')
  end

  def test_to_json_includes_all_required_fields
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    assert_equal 123_456, json['merchantId']
    assert_equal 123_456, json['posId']
    assert_equal 'test_session_123', json['sessionId']
    assert_equal 10_000, json['amount']
    assert_equal 'PLN', json['currency']
    assert_equal 'Test payment', json['description']
    assert_equal 'test@example.com', json['email']
    assert_equal 'PL', json['country']
    assert_equal 'pl', json['language']
    assert_equal 'https://example.com/return', json['urlReturn']
    assert json.key?('sign')
  end

  def test_to_json_includes_optional_fields_when_present
    params = @required_params.merge(
      client: 'Jan Kowalski',
      url_status: 'https://example.com/status',
      time_limit: 15
    )

    transaction = P24::Api::V1::Request::TransactionRegister.new(**params)
    json = JSON.parse(transaction.to_json)

    assert_equal 'Jan Kowalski', json['client']
    assert_equal 'https://example.com/status', json['urlStatus']
    assert_equal 15, json['timeLimit']
  end

  def test_to_json_excludes_nil_values
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    refute json.key?('client')
    refute json.key?('address')
    refute json.key?('zip')
    refute json.key?('city')
    refute json.key?('phone')
    refute json.key?('method')
    refute json.key?('urlStatus')
  end

  def test_to_json_excludes_crc_field
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)
    json = JSON.parse(transaction.to_json)

    refute json.key?('crc')
  end

  def test_sign_generates_sha384_hash
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)
    json = JSON.parse(transaction.to_json)
    sign = json['sign']

    assert_equal 96, sign.length
    assert_match(/\A[a-f0-9]{96}\z/, sign)
  end

  def test_sign_is_deterministic
    transaction1 = P24::Api::V1::Request::TransactionRegister.new(**@required_params)
    transaction2 = P24::Api::V1::Request::TransactionRegister.new(**@required_params)

    json1 = JSON.parse(transaction1.to_json)
    json2 = JSON.parse(transaction2.to_json)

    assert_equal json1['sign'], json2['sign']
  end

  def test_sign_changes_with_different_params
    transaction1 = P24::Api::V1::Request::TransactionRegister.new(**@required_params)

    different_params = @required_params.merge(amount: 20_000)
    transaction2 = P24::Api::V1::Request::TransactionRegister.new(**different_params)

    json1 = JSON.parse(transaction1.to_json)
    json2 = JSON.parse(transaction2.to_json)

    refute_equal json1['sign'], json2['sign']
  end

  def test_sign_based_on_specific_params
    transaction = P24::Api::V1::Request::TransactionRegister.new(**@required_params)

    expected_sign_params = {
      sessionId: 'test_session_123',
      merchantId: 123_456,
      amount: 10_000,
      currency: 'PLN',
      crc: 'test_crc_key'
    }
    expected_sign = Digest::SHA384.hexdigest(expected_sign_params.to_json)

    json = JSON.parse(transaction.to_json)
    assert_equal expected_sign, json['sign']
  end

  def test_to_json_with_all_fields
    params = @required_params.merge(
      client: 'Jan Kowalski',
      address: 'ul. Testowa 1',
      zip: '00-001',
      city: 'Warszawa',
      phone: '+48123456789',
      method: 25,
      url_status: 'https://example.com/status',
      time_limit: 15,
      channel: 1,
      wait_for_result: true,
      regulation_accept: true,
      shipping: 500,
      transfer_label: 'Test transfer',
      mobile_lib: true,
      sdk_version: '1.0',
      encoding: 'UTF-8',
      method_ref_id: 'ref_123'
    )

    transaction = P24::Api::V1::Request::TransactionRegister.new(**params)
    json_string = transaction.to_json

    assert_instance_of String, json_string

    json = JSON.parse(json_string)
    assert_instance_of Hash, json
    assert json.key?('sign')
    assert_equal 'Jan Kowalski', json['client']
    assert_equal 'ul. Testowa 1', json['address']
    assert_equal '00-001', json['zip']
    assert_equal 'Warszawa', json['city']
    assert_equal '+48123456789', json['phone']
    assert_equal 25, json['method']
    assert_equal 'https://example.com/status', json['urlStatus']
    assert_equal 15, json['timeLimit']
    assert_equal 1, json['channel']
    assert json['waitForResult']
    assert json['regulationAccept']
    assert_equal 500, json['shipping']
    assert_equal 'Test transfer', json['transferLabel']
    assert json['mobileLib']
    assert_equal '1.0', json['sdkVersion']
    assert_equal 'UTF-8', json['encoding']
    assert_equal 'ref_123', json['methodRefId']
  end
end
