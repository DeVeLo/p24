# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestTransactionRegisterResponse < Minitest::Test
  def setup
    @sample_data = { 'token' => 'abc123xyz' }
    @sample_response_code = 0
  end

  def test_initialization_with_data_and_response_code
    response = P24::Api::V1::Response::TransactionRegister.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    assert_equal 'abc123xyz', response.data.token
    assert_equal 0, response.response_code
  end

  def test_initialization_with_different_token
    data = { 'token' => 'different_token_456' }
    response = P24::Api::V1::Response::TransactionRegister.new(
      data:,
      response_code: 1
    )

    assert_equal 'different_token_456', response.data.token
    assert_equal 1, response.response_code
  end

  def test_data_is_a_struct
    response = P24::Api::V1::Response::TransactionRegister.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    assert_instance_of P24::Api::V1::Response::TransactionRegister::Data, response.data
    assert_respond_to response.data, :token
  end

  def test_to_json_includes_data_and_response_code
    response = P24::Api::V1::Response::TransactionRegister.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    json = JSON.parse(response.to_json)

    assert json.key?('data')
    assert json.key?('response_code')
  end

  def test_to_json_preserves_data_structure
    response = P24::Api::V1::Response::TransactionRegister.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    json = JSON.parse(response.to_json)

    assert_equal 'abc123xyz', json['data']['token']
    assert_equal 0, json['response_code']
  end

  def test_from_json_creates_instance_from_json_hash
    json_hash = {
      'data' => { 'token' => 'from_json_token' },
      'responseCode' => 2
    }

    response = P24::Api::V1::Response::TransactionRegister.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::TransactionRegister, response
    assert_equal 'from_json_token', response.data.token
    assert_equal 2, response.response_code
  end

  def test_from_json_uses_camel_case_keys
    json_hash = {
      'data' => { 'token' => 'camelCase_token' },
      'responseCode' => 0
    }

    response = P24::Api::V1::Response::TransactionRegister.from_json(json_hash)

    assert_equal 'camelCase_token', response.data.token
    assert_equal 0, response.response_code
  end

  def test_round_trip_conversion
    original_json = {
      'data' => { 'token' => 'roundtrip_token' },
      'responseCode' => 0
    }

    response = P24::Api::V1::Response::TransactionRegister.from_json(original_json)
    converted_json = JSON.parse(response.to_json)

    assert_equal original_json['data']['token'], converted_json['data']['token']
    assert_equal original_json['responseCode'], converted_json['response_code']
  end

  def test_handles_nil_token_in_data
    data = { 'token' => nil }
    response = P24::Api::V1::Response::TransactionRegister.new(
      data:,
      response_code: 0
    )

    assert_nil response.data.token
  end

  def test_handles_empty_data_hash
    data = {}
    response = P24::Api::V1::Response::TransactionRegister.new(
      data:,
      response_code: 0
    )

    assert_nil response.data.token
  end

  def test_to_json_returns_valid_json_string
    response = P24::Api::V1::Response::TransactionRegister.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    json_string = response.to_json

    assert_instance_of String, json_string

    parsed = JSON.parse(json_string)
    assert_instance_of Hash, parsed
  end

  def test_different_response_codes
    [0, 1, 404, 500].each do |code|
      response = P24::Api::V1::Response::TransactionRegister.new(
        data: @sample_data,
        response_code: code
      )

      assert_equal code, response.response_code
    end
  end
end
