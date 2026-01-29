# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestTestAccess < Minitest::Test
  def setup
    @sample_data = { 'token' => 'test_token_123', 'expiry' => '2026-12-31' }
    @sample_error = nil
  end

  def test_initialization_with_data_and_error
    response = P24::Api::V1::Response::TestAccess.new(
      data: @sample_data,
      error: @sample_error
    )

    assert_equal @sample_data, response.data
    assert_nil response.error
  end

  def test_initialization_with_error
    error = 'Invalid credentials'
    response = P24::Api::V1::Response::TestAccess.new(
      data: nil,
      error:
    )

    assert_nil response.data
    assert_equal 'Invalid credentials', response.error
  end

  def test_initialization_with_both_data_and_error
    error = 'Warning message'
    response = P24::Api::V1::Response::TestAccess.new(
      data: @sample_data,
      error:
    )

    assert_equal @sample_data, response.data
    assert_equal 'Warning message', response.error
  end

  def test_attributes_are_read_only
    response = P24::Api::V1::Response::TestAccess.new(
      data: @sample_data,
      error: @sample_error
    )

    refute_respond_to response, :data=
    refute_respond_to response, :error=
  end

  def test_to_json_includes_data_and_error
    response = P24::Api::V1::Response::TestAccess.new(
      data: @sample_data,
      error: @sample_error
    )

    json = JSON.parse(response.to_json)

    assert json.key?('data')
    assert json.key?('error')
  end

  def test_to_json_preserves_data_structure
    response = P24::Api::V1::Response::TestAccess.new(
      data: @sample_data,
      error: @sample_error
    )

    json = JSON.parse(response.to_json)

    assert_equal @sample_data, json['data']
    assert_nil json['error']
  end

  def test_to_json_preserves_error
    error = 'Authentication failed'
    response = P24::Api::V1::Response::TestAccess.new(
      data: nil,
      error:
    )

    json = JSON.parse(response.to_json)

    assert_nil json['data']
    assert_equal 'Authentication failed', json['error']
  end

  def test_to_json_returns_valid_json_string
    response = P24::Api::V1::Response::TestAccess.new(
      data: @sample_data,
      error: @sample_error
    )

    json_string = response.to_json

    assert_instance_of String, json_string

    parsed = JSON.parse(json_string)
    assert_instance_of Hash, parsed
  end

  def test_from_json_creates_instance_from_json_hash
    json_hash = {
      'data' => @sample_data,
      'error' => nil
    }

    response = P24::Api::V1::Response::TestAccess.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::TestAccess, response
    assert_equal @sample_data, response.data
    assert_nil response.error
  end

  def test_from_json_with_error
    json_hash = {
      'data' => nil,
      'error' => 'Connection timeout'
    }

    response = P24::Api::V1::Response::TestAccess.from_json(json_hash)

    assert_nil response.data
    assert_equal 'Connection timeout', response.error
  end

  def test_round_trip_conversion
    original_json = {
      'data' => @sample_data,
      'error' => nil
    }

    response = P24::Api::V1::Response::TestAccess.from_json(original_json)
    converted_json = JSON.parse(response.to_json)

    assert_equal original_json['data'], converted_json['data']
    assert_nil converted_json['error']
  end

  def test_round_trip_conversion_with_error
    original_json = {
      'data' => nil,
      'error' => 'Service unavailable'
    }

    response = P24::Api::V1::Response::TestAccess.from_json(original_json)
    converted_json = JSON.parse(response.to_json)

    assert_nil converted_json['data']
    assert_equal original_json['error'], converted_json['error']
  end

  def test_handles_empty_data_hash
    data = {}
    response = P24::Api::V1::Response::TestAccess.new(
      data:,
      error: nil
    )

    assert_empty(response.data)
    assert_nil response.error
  end

  def test_handles_complex_data_structure
    complex_data = {
      'token' => 'abc123',
      'expiry' => '2026-12-31',
      'permissions' => %w[read write],
      'metadata' => { 'created_at' => '2026-01-29' }
    }

    response = P24::Api::V1::Response::TestAccess.new(
      data: complex_data,
      error: nil
    )

    assert_equal complex_data, response.data
  end

  def test_handles_different_error_types
    ['String error', 123, { 'code' => 'ERR_001' }].each do |error|
      response = P24::Api::V1::Response::TestAccess.new(
        data: nil,
        error:
      )

      assert_equal error, response.error
    end
  end

  def test_from_json_with_both_nil_values
    json_hash = {
      'data' => nil,
      'error' => nil
    }

    response = P24::Api::V1::Response::TestAccess.from_json(json_hash)

    assert_nil response.data
    assert_nil response.error
  end
end
