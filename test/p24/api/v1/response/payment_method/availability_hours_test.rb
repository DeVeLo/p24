# frozen_string_literal: true

require 'test_helper'
require 'json'

class TestAvailabilityHours < Minitest::Test
  def setup
    @monday_friday_hours = '08:00-18:00'
    @saturday_hours = '10:00-14:00'
    @sunday_hours = 'closed'
  end

  def test_inicjalizacja_z_podstawowymi_parametrami
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: @monday_friday_hours,
      saturday: @saturday_hours,
      sunday: @sunday_hours
    )

    assert_equal '08:00-18:00', hours.monday_to_friday
    assert_equal '10:00-14:00', hours.saturday
    assert_equal 'closed', hours.sunday
  end

  def test_inicjalizacja_z_roznymi_wartosciami_godzin
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: '06:00-22:00',
      saturday: '08:00-20:00',
      sunday: '09:00-15:00'
    )

    assert_equal '06:00-22:00', hours.monday_to_friday
    assert_equal '08:00-20:00', hours.saturday
    assert_equal '09:00-15:00', hours.sunday
  end

  def test_inicjalizacja_z_calodzienna_dostepnoscia
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: '24/7',
      saturday: '24/7',
      sunday: '24/7'
    )

    assert_equal '24/7', hours.monday_to_friday
    assert_equal '24/7', hours.saturday
    assert_equal '24/7', hours.sunday
  end

  def test_to_json_zwraca_poprawna_strukture
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: @monday_friday_hours,
      saturday: @saturday_hours,
      sunday: @sunday_hours
    )

    json = JSON.parse(hours.to_json)

    assert json.key?('monday_to_friday')
    assert json.key?('saturday')
    assert json.key?('sunday')
  end

  def test_to_json_zachowuje_wartosci_godzin
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: @monday_friday_hours,
      saturday: @saturday_hours,
      sunday: @sunday_hours
    )

    json = JSON.parse(hours.to_json)

    assert_equal '08:00-18:00', json['monday_to_friday']
    assert_equal '10:00-14:00', json['saturday']
    assert_equal 'closed', json['sunday']
  end

  def test_to_json_zwraca_poprawny_string_json
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: @monday_friday_hours,
      saturday: @saturday_hours,
      sunday: @sunday_hours
    )

    json_string = hours.to_json

    assert_instance_of String, json_string

    parsed = JSON.parse(json_string)
    assert_instance_of Hash, parsed
  end

  def test_from_json_tworzy_instancje_z_hasza_json
    json_hash = {
      'mondayToFriday' => '09:00-17:00',
      'saturday' => '10:00-16:00',
      'sunday' => 'closed'
    }

    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.from_json(json_hash)

    assert_instance_of P24::Api::V1::Response::PaymentMethod::AvailabilityHours, hours
    assert_equal '09:00-17:00', hours.monday_to_friday
    assert_equal '10:00-16:00', hours.saturday
    assert_equal 'closed', hours.sunday
  end

  def test_from_json_uzywa_kluczy_w_formacie_camel_case
    json_hash = {
      'mondayToFriday' => '07:00-19:00',
      'saturday' => '08:00-14:00',
      'sunday' => '00:00-00:00'
    }

    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.from_json(json_hash)

    assert_equal '07:00-19:00', hours.monday_to_friday
    assert_equal '08:00-14:00', hours.saturday
    assert_equal '00:00-00:00', hours.sunday
  end

  def test_konwersja_round_trip
    original_json = {
      'mondayToFriday' => '06:00-22:00',
      'saturday' => '10:00-18:00',
      'sunday' => 'closed'
    }

    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.from_json(original_json)
    converted_json = JSON.parse(hours.to_json)

    assert_equal original_json['mondayToFriday'], converted_json['monday_to_friday']
    assert_equal original_json['saturday'], converted_json['saturday']
    assert_equal original_json['sunday'], converted_json['sunday']
  end

  def test_obsluga_wartosci_nil
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: nil,
      saturday: nil,
      sunday: nil
    )

    assert_nil hours.monday_to_friday
    assert_nil hours.saturday
    assert_nil hours.sunday
  end

  def test_obsluga_wartosci_nil_w_from_json
    json_hash = {
      'mondayToFriday' => nil,
      'saturday' => nil,
      'sunday' => nil
    }

    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.from_json(json_hash)

    assert_nil hours.monday_to_friday
    assert_nil hours.saturday
    assert_nil hours.sunday
  end

  def test_obsluga_pustych_stringow
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: '',
      saturday: '',
      sunday: ''
    )

    assert_equal '', hours.monday_to_friday
    assert_equal '', hours.saturday
    assert_equal '', hours.sunday
  end

  def test_to_json_z_wartosciami_nil
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: nil,
      saturday: nil,
      sunday: nil
    )

    json = JSON.parse(hours.to_json)

    assert_nil json['monday_to_friday']
    assert_nil json['saturday']
    assert_nil json['sunday']
  end

  def test_atrybuty_sa_tylko_do_odczytu
    hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
      monday_to_friday: @monday_friday_hours,
      saturday: @saturday_hours,
      sunday: @sunday_hours
    )

    refute_respond_to hours, :monday_to_friday=
    refute_respond_to hours, :saturday=
    refute_respond_to hours, :sunday=
  end

  def test_rozne_formaty_godzin
    formats = [
      '00:00-23:59',
      '24h',
      'Non-stop',
      'By appointment',
      'Closed',
      '8-18'
    ]

    formats.each do |format|
      hours = P24::Api::V1::Response::PaymentMethod::AvailabilityHours.new(
        monday_to_friday: format,
        saturday: format,
        sunday: format
      )

      assert_equal format, hours.monday_to_friday
      assert_equal format, hours.saturday
      assert_equal format, hours.sunday
    end
  end
end
