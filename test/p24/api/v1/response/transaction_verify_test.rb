# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestTransactionVerifyResponse < Minitest::Test
  def setup
    @sample_data = { 'status' => 'success' }
    @sample_response_code = 0
  end

  def test_initialization_with_data_and_response_code
    response = P24::Api::V1::Response::TransactionVerify.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    assert_equal 'success', response.data.status
    assert_equal 0, response.response_code
  end

  def test_initialization_with_different_status
    data = { 'status' => 'failed' }
    response = P24::Api::V1::Response::TransactionVerify.new(
      data:,
      response_code: 1
    )

    assert_equal 'failed', response.data.status
    assert_equal 1, response.response_code
  end

  def test_data_is_a_struct
    response = P24::Api::V1::Response::TransactionVerify.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    assert_instance_of P24::Api::V1::Response::TransactionVerify::Data, response.data
    assert_respond_to response.data, :status
  end

  def test_to_json_includes_data_and_response_code
    response = P24::Api::V1::Response::TransactionVerify.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    json = JSON.parse(response.to_json)

    assert json.key?('data')
    assert json.key?('response_code')
  end

  def test_to_json_preserves_data_structure
    response = P24::Api::V1::Response::TransactionVerify.new(
      data: @sample_data,
      response_code: @sample_response_code
    )

    json = JSON.parse(response.to_json)

    assert_equal 'success', json['data']['status']
    assert_equal 0, json['response_code']
  end

  def test_from_json_creates_instance_from_json_hash
    json_hash = {
      'data' => { 'status' => 'pending' },
      'responseCode' => 2
    }

    response = P24::Api::V1::Response::TransactionVerify.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::TransactionVerify, response
    assert_equal 'pending', response.data.status
    assert_equal 2, response.response_code
  end

  def test_from_json_uses_camel_case_keys
    json_hash = {
      'data' => { 'status' => 'completed' },
      'responseCode' => 0
    }

    response = P24::Api::V1::Response::TransactionVerify.from_json(json_hash)

    assert_equal 'completed', response.data.status
    assert_equal 0, response.response_code
  end

  def test_round_trip_conversion
    original_json = {
      'data' => { 'status' => 'verified' },
      'responseCode' => 0
    }

    response = P24::Api::V1::Response::TransactionVerify.from_json(original_json)
    converted_json = JSON.parse(response.to_json)

    assert_equal original_json['data']['status'], converted_json['data']['status']
    assert_equal original_json['responseCode'], converted_json['response_code']
  end

  def test_handles_nil_status_in_data
    data = { 'status' => nil }
    response = P24::Api::V1::Response::TransactionVerify.new(
      data:,
      response_code: 0
    )

    assert_nil response.data.status
  end

  def test_handles_empty_data_hash
    data = {}
    response = P24::Api::V1::Response::TransactionVerify.new(
      data:,
      response_code: 0
    )

    assert_nil response.data.status
  end

  def test_to_json_returns_valid_json_string
    response = P24::Api::V1::Response::TransactionVerify.new(
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
      response = P24::Api::V1::Response::TransactionVerify.new(
        data: @sample_data,
        response_code: code
      )

      assert_equal code, response.response_code
    end
  end
end
