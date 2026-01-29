# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestPaymentMethods < Minitest::Test
  def setup
    @availability_hours_data = {
      'mondayToFriday' => '08:00-18:00',
      'saturday' => '10:00-14:00',
      'sunday' => 'closed'
    }

    @payment_method_data1 = {
      'name' => 'Karta kredytowa',
      'id' => 25,
      'group' => 'cards',
      'subgroup' => 'visa',
      'status' => 'active',
      'imgUrl' => 'https://example.com/visa.png',
      'mobileImgUrl' => 'https://example.com/visa-mobile.png',
      'mobile' => true,
      'availabilityHours' => @availability_hours_data
    }

    @payment_method_data2 = {
      'name' => 'BLIK',
      'id' => 99,
      'group' => 'instant',
      'subgroup' => 'mobile',
      'status' => 'active',
      'imgUrl' => 'https://example.com/blik.png',
      'mobileImgUrl' => 'https://example.com/blik-mobile.png',
      'mobile' => true,
      'availabilityHours' => @availability_hours_data
    }

    @sample_data = [@payment_method_data1, @payment_method_data2]
    @sample_agreements = ['Regulamin serwisu', 'Polityka prywatności']
    @sample_response_code = 0
  end

  def test_initialization_with_all_parameters
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    assert_equal 2, payment_methods.data.length
    assert_equal @sample_agreements, payment_methods.agreements
    assert_equal 0, payment_methods.response_code
  end

  def test_initialization_creates_array_of_payment_method_data_objects
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    payment_methods.data.each do |item|
      assert_instance_of P24::Api::V1::Response::PaymentMethod::Data, item
    end
  end

  def test_initialization_preserves_details_of_each_payment_method
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    first_method = payment_methods.data[0]
    assert_equal 'Karta kredytowa', first_method.name
    assert_equal 25, first_method.id
    assert_equal 'cards', first_method.group

    second_method = payment_methods.data[1]
    assert_equal 'BLIK', second_method.name
    assert_equal 99, second_method.id
    assert_equal 'instant', second_method.group
  end

  def test_initialization_with_empty_data_array
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: [],
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    assert_equal 0, payment_methods.data.length
    assert_equal @sample_agreements, payment_methods.agreements
  end

  def test_initialization_with_empty_agreements_array
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: [],
      response_code: @sample_response_code
    )

    assert_equal 2, payment_methods.data.length
    assert_empty payment_methods.agreements
  end

  def test_initialization_with_different_response_codes
    [0, 1, 200, 404, 500].each do |code|
      payment_methods = P24::Api::V1::Response::PaymentMethods.new(
        data: @sample_data,
        agreements: @sample_agreements,
        response_code: code
      )

      assert_equal code, payment_methods.response_code
    end
  end

  def test_to_json_returns_correct_structure
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    json = JSON.parse(payment_methods.to_json)

    assert json.key?('data')
    assert json.key?('agreements')
    assert json.key?('response_code')
  end

  def test_to_json_preserves_all_values
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    json = JSON.parse(payment_methods.to_json)

    assert_equal 2, json['data'].length
    assert_equal @sample_agreements, json['agreements']
    assert_equal 0, json['response_code']
  end

  def test_to_json_contains_payment_method_details
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    json = JSON.parse(payment_methods.to_json)

    first_method = json['data'][0]
    assert_equal 'Karta kredytowa', first_method['name']
    assert_equal 25, first_method['id']

    second_method = json['data'][1]
    assert_equal 'BLIK', second_method['name']
    assert_equal 99, second_method['id']
  end

  def test_to_json_returns_valid_json_string
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    json_string = payment_methods.to_json

    assert_instance_of String, json_string

    parsed = JSON.parse(json_string)
    assert_instance_of Hash, parsed
  end

  def test_from_json_creates_instance_from_json_hash
    json_hash = {
      'data' => @sample_data,
      'agreements' => @sample_agreements,
      'responseCode' => @sample_response_code
    }

    payment_methods = P24::Api::V1::Response::PaymentMethods.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::PaymentMethods, payment_methods
    assert_equal 2, payment_methods.data.length
    assert_equal @sample_agreements, payment_methods.agreements
    assert_equal 0, payment_methods.response_code
  end

  def test_from_json_uses_camel_case_keys
    json_hash = {
      'data' => @sample_data,
      'agreements' => ['Umowa 1', 'Umowa 2'],
      'responseCode' => 200
    }

    payment_methods = P24::Api::V1::Response::PaymentMethods.from_json(json_hash)

    assert_equal ['Umowa 1', 'Umowa 2'], payment_methods.agreements
    assert_equal 200, payment_methods.response_code
  end

  def test_from_json_creates_payment_method_data_objects
    json_hash = {
      'data' => @sample_data,
      'agreements' => @sample_agreements,
      'responseCode' => @sample_response_code
    }

    payment_methods = P24::Api::V1::Response::PaymentMethods.from_json(json_hash)

    payment_methods.data.each do |item|
      assert_instance_of P24::Api::V1::Response::PaymentMethod::Data, item
    end

    assert_equal 'Karta kredytowa', payment_methods.data[0].name
    assert_equal 'BLIK', payment_methods.data[1].name
  end

  def test_round_trip_conversion
    original_json = {
      'data' => @sample_data,
      'agreements' => @sample_agreements,
      'responseCode' => 0
    }

    payment_methods = P24::Api::V1::Response::PaymentMethods.from_json(original_json)
    converted_json = JSON.parse(payment_methods.to_json)

    assert_equal original_json['data'].length, converted_json['data'].length
    assert_equal original_json['agreements'], converted_json['agreements']
    assert_equal original_json['responseCode'], converted_json['response_code']
  end

  def test_round_trip_conversion_preserves_payment_method_details
    original_json = {
      'data' => @sample_data,
      'agreements' => @sample_agreements,
      'responseCode' => 0
    }

    payment_methods = P24::Api::V1::Response::PaymentMethods.from_json(original_json)
    converted_json = JSON.parse(payment_methods.to_json)

    original_json['data'].each_with_index do |original_method, index|
      converted_method = converted_json['data'][index]

      assert_equal original_method['name'], converted_method['name']
      assert_equal original_method['id'], converted_method['id']
      assert_equal original_method['group'], converted_method['group']
    end
  end

  def test_attributes_are_read_only
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    refute_respond_to payment_methods, :data=
    refute_respond_to payment_methods, :agreements=
    refute_respond_to payment_methods, :response_code=
  end

  def test_handles_single_payment_method
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: [@payment_method_data1],
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    assert_equal 1, payment_methods.data.length
    assert_equal 'Karta kredytowa', payment_methods.data[0].name
  end

  def test_handles_multiple_payment_methods
    additional_method = {
      'name' => 'PayPal',
      'id' => 30,
      'group' => 'wallets',
      'subgroup' => 'digital',
      'status' => 'active',
      'imgUrl' => 'https://example.com/paypal.png',
      'mobileImgUrl' => 'https://example.com/paypal-mobile.png',
      'mobile' => true,
      'availabilityHours' => @availability_hours_data
    }

    all_data = @sample_data + [additional_method]

    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: all_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    assert_equal 3, payment_methods.data.length
    assert_equal 'Karta kredytowa', payment_methods.data[0].name
    assert_equal 'BLIK', payment_methods.data[1].name
    assert_equal 'PayPal', payment_methods.data[2].name
  end

  def test_handles_different_agreement_types
    [
      ['Regulamin 1'],
      ['Regulamin 1', 'Regulamin 2'],
      ['Regulamin 1', 'Regulamin 2', 'Regulamin 3', 'Regulamin 4'],
      []
    ].each do |agreements|
      payment_methods = P24::Api::V1::Response::PaymentMethods.new(
        data: @sample_data,
        agreements:,
        response_code: @sample_response_code
      )

      assert_equal agreements, payment_methods.agreements
    end
  end

  def test_to_json_with_empty_data_array
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: [],
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    json = JSON.parse(payment_methods.to_json)

    assert_empty json['data']
    assert_equal @sample_agreements, json['agreements']
    assert_equal 0, json['response_code']
  end

  def test_from_json_with_empty_data_array
    json_hash = {
      'data' => [],
      'agreements' => @sample_agreements,
      'responseCode' => 0
    }

    payment_methods = P24::Api::V1::Response::PaymentMethods.from_json(json_hash)

    assert_equal 0, payment_methods.data.length
    assert_equal @sample_agreements, payment_methods.agreements
  end

  def test_data_mapping_preserves_order
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    assert_equal 'Karta kredytowa', payment_methods.data[0].name
    assert_equal 'BLIK', payment_methods.data[1].name
    assert_equal 25, payment_methods.data[0].id
    assert_equal 99, payment_methods.data[1].id
  end

  def test_data_contains_complete_objects_with_availability_hours
    payment_methods = P24::Api::V1::Response::PaymentMethods.new(
      data: @sample_data,
      agreements: @sample_agreements,
      response_code: @sample_response_code
    )

    payment_methods.data.each do |method|
      assert_instance_of P24::Api::V1::Response::PaymentMethod::AvailabilityHours, method.availability_hours
      assert_equal '08:00-18:00', method.availability_hours.monday_to_friday
    end
  end
end
