# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestPaymentMethodData < Minitest::Test
  def setup
    @availability_hours_data = {
      'mondayToFriday' => '08:00-18:00',
      'saturday' => '10:00-14:00',
      'sunday' => 'closed'
    }

    @sample_data = {
      name: 'Credit Card',
      id: 25,
      group: 'cards',
      subgroup: 'visa',
      status: 'active',
      img_url: 'https://example.com/card.png',
      mobile_img_url: 'https://example.com/card-mobile.png',
      mobile: true,
      availability_hours: @availability_hours_data
    }
  end

  def test_inicjalizacja_z_wszystkimi_parametrami
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)

    assert_equal 'Credit Card', data.name
    assert_equal 25, data.id
    assert_equal 'cards', data.group
    assert_equal 'visa', data.subgroup
    assert_equal 'active', data.status
    assert_equal 'https://example.com/card.png', data.img_url
    assert_equal 'https://example.com/card-mobile.png', data.mobile_img_url
    assert data.mobile
    assert_instance_of P24::Api::V1::Response::PaymentMethod::AvailabilityHours, data.availability_hours
  end

  def test_inicjalizacja_tworzy_obiekt_availability_hours
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)

    assert_equal '08:00-18:00', data.availability_hours.monday_to_friday
    assert_equal '10:00-14:00', data.availability_hours.saturday
    assert_equal 'closed', data.availability_hours.sunday
  end

  def test_inicjalizacja_z_roznymi_wartosciami
    params = {
      name: 'Bank Transfer',
      id: 1,
      group: 'transfers',
      subgroup: 'instant',
      status: 'inactive',
      img_url: 'https://example.com/transfer.png',
      mobile_img_url: 'https://example.com/transfer-mobile.png',
      mobile: false,
      availability_hours: @availability_hours_data
    }

    data = P24::Api::V1::Response::PaymentMethod::Data.new(**params)

    assert_equal 'Bank Transfer', data.name
    assert_equal 1, data.id
    assert_equal 'transfers', data.group
    assert_equal 'instant', data.subgroup
    assert_equal 'inactive', data.status
    refute data.mobile
  end

  def test_to_json_zwraca_poprawna_strukture
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)
    json = JSON.parse(data.to_json)

    assert json.key?('name')
    assert json.key?('id')
    assert json.key?('group')
    assert json.key?('subgroup')
    assert json.key?('status')
    assert json.key?('img_url')
    assert json.key?('mobile_img_url')
    assert json.key?('mobile')
    assert json.key?('availability_hours')
  end

  def test_to_json_zachowuje_wszystkie_wartosci
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)
    json = JSON.parse(data.to_json)

    assert_equal 'Credit Card', json['name']
    assert_equal 25, json['id']
    assert_equal 'cards', json['group']
    assert_equal 'visa', json['subgroup']
    assert_equal 'active', json['status']
    assert_equal 'https://example.com/card.png', json['img_url']
    assert_equal 'https://example.com/card-mobile.png', json['mobile_img_url']
    assert json['mobile']
  end

  def test_to_json_zawiera_availability_hours_jako_obiekt
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)
    json = JSON.parse(data.to_json)

    assert_instance_of Hash, json['availability_hours']
    assert_equal '08:00-18:00', json['availability_hours']['monday_to_friday']
    assert_equal '10:00-14:00', json['availability_hours']['saturday']
    assert_equal 'closed', json['availability_hours']['sunday']
  end

  def test_to_json_zwraca_poprawny_string_json
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)
    json_string = data.to_json

    assert_instance_of String, json_string

    parsed = JSON.parse(json_string)
    assert_instance_of Hash, parsed
  end

  def test_from_json_tworzy_instancje_z_hasza_json
    json_hash = {
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

    data = P24::Api::V1::Response::PaymentMethod::Data.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::PaymentMethod::Data, data
    assert_equal 'PayPal', data.name
    assert_equal 30, data.id
    assert_equal 'wallets', data.group
    assert_equal 'digital', data.subgroup
    assert_equal 'active', data.status
    assert_equal 'https://example.com/paypal.png', data.img_url
    assert_equal 'https://example.com/paypal-mobile.png', data.mobile_img_url
    assert data.mobile
  end

  def test_from_json_uzywa_kluczy_w_formacie_camel_case
    json_hash = {
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

    data = P24::Api::V1::Response::PaymentMethod::Data.from_json(json_hash)

    assert_equal 'https://example.com/blik.png', data.img_url
    assert_equal 'https://example.com/blik-mobile.png', data.mobile_img_url
  end

  def test_from_json_tworzy_availability_hours
    json_hash = {
      'name' => 'Test',
      'id' => 1,
      'group' => 'test',
      'subgroup' => 'test',
      'status' => 'active',
      'imgUrl' => 'https://example.com/test.png',
      'mobileImgUrl' => 'https://example.com/test-mobile.png',
      'mobile' => true,
      'availabilityHours' => {
        'mondayToFriday' => '09:00-17:00',
        'saturday' => '10:00-15:00',
        'sunday' => 'closed'
      }
    }

    data = P24::Api::V1::Response::PaymentMethod::Data.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::PaymentMethod::AvailabilityHours, data.availability_hours
    assert_equal '09:00-17:00', data.availability_hours.monday_to_friday
    assert_equal '10:00-15:00', data.availability_hours.saturday
    assert_equal 'closed', data.availability_hours.sunday
  end

  def test_konwersja_round_trip
    original_json = {
      'name' => 'Visa',
      'id' => 25,
      'group' => 'cards',
      'subgroup' => 'credit',
      'status' => 'active',
      'imgUrl' => 'https://example.com/visa.png',
      'mobileImgUrl' => 'https://example.com/visa-mobile.png',
      'mobile' => true,
      'availabilityHours' => @availability_hours_data
    }

    data = P24::Api::V1::Response::PaymentMethod::Data.from_json(original_json)
    converted_json = JSON.parse(data.to_json)

    assert_equal original_json['name'], converted_json['name']
    assert_equal original_json['id'], converted_json['id']
    assert_equal original_json['group'], converted_json['group']
    assert_equal original_json['subgroup'], converted_json['subgroup']
    assert_equal original_json['status'], converted_json['status']
    assert_equal original_json['imgUrl'], converted_json['img_url']
    assert_equal original_json['mobileImgUrl'], converted_json['mobile_img_url']
    assert_equal original_json['mobile'], converted_json['mobile']
  end

  def test_atrybuty_sa_tylko_do_odczytu
    data = P24::Api::V1::Response::PaymentMethod::Data.new(**@sample_data)

    refute_respond_to data, :name=
    refute_respond_to data, :id=
    refute_respond_to data, :group=
    refute_respond_to data, :subgroup=
    refute_respond_to data, :status=
    refute_respond_to data, :img_url=
    refute_respond_to data, :mobile_img_url=
    refute_respond_to data, :mobile=
    refute_respond_to data, :availability_hours=
  end

  def test_obsluga_wartosci_nil
    params = {
      name: nil,
      id: nil,
      group: nil,
      subgroup: nil,
      status: nil,
      img_url: nil,
      mobile_img_url: nil,
      mobile: nil,
      availability_hours: @availability_hours_data
    }

    data = P24::Api::V1::Response::PaymentMethod::Data.new(**params)

    assert_nil data.name
    assert_nil data.id
    assert_nil data.group
    assert_nil data.subgroup
    assert_nil data.status
    assert_nil data.img_url
    assert_nil data.mobile_img_url
    assert_nil data.mobile
  end

  def test_obsluga_roznych_typow_id
    [1, 99, 123, 9999].each do |payment_id|
      params = @sample_data.merge(id: payment_id)
      data = P24::Api::V1::Response::PaymentMethod::Data.new(**params)

      assert_equal payment_id, data.id
    end
  end

  def test_obsluga_roznych_statusow
    %w[active inactive pending disabled].each do |payment_status|
      params = @sample_data.merge(status: payment_status)
      data = P24::Api::V1::Response::PaymentMethod::Data.new(**params)

      assert_equal payment_status, data.status
    end
  end

  def test_obsluga_wartosci_boolean_mobile
    [true, false].each do |mobile_value|
      params = @sample_data.merge(mobile: mobile_value)
      data = P24::Api::V1::Response::PaymentMethod::Data.new(**params)

      assert_equal mobile_value, data.mobile
    end
  end

  def test_obsluga_pustych_stringow
    params = {
      name: '',
      id: 0,
      group: '',
      subgroup: '',
      status: '',
      img_url: '',
      mobile_img_url: '',
      mobile: false,
      availability_hours: @availability_hours_data
    }

    data = P24::Api::V1::Response::PaymentMethod::Data.new(**params)

    assert_equal '', data.name
    assert_equal 0, data.id
    assert_equal '', data.group
    assert_equal '', data.subgroup
    assert_equal '', data.status
    assert_equal '', data.img_url
    assert_equal '', data.mobile_img_url
  end
end
