# frozen_string_literal: true

require 'test_helper'

class TestP24 < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::P24::VERSION
  end
end

class TestPrzelewy24Alias < Minitest::Test
  def test_przelewy24_constant_is_defined
    assert defined?(Przelewy24), 'Przelewy24 constant should be defined'
  end

  def test_przelewy24_is_alias_to_p24_client
    assert_equal P24::Client, Przelewy24, 'Przelewy24 should be an alias to P24::Client'
  end

  def test_can_create_instance_using_przelewy24
    client = Przelewy24.new(
      user: 'test_user',
      secret_id: 'test_secret',
      crc: 'test_crc'
    )

    assert_instance_of P24::Client, client, 'Instance created using Przelewy24 should be an instance of P24::Client'
  end

  def test_przelewy24_instance_has_same_attributes_as_p24_client
    client = Przelewy24.new(
      user: 'test_user',
      secret_id: 'test_secret',
      crc: 'test_crc',
      base_url: 'https://example.com',
      timeout: 60,
      encoding: 'ISO-8859-2',
      debug: true
    )

    assert_equal 'test_user', client.user
    assert_equal 'test_secret', client.secret_id
    assert_equal 'test_crc', client.crc
    assert_equal 'https://example.com', client.base_url
    assert_equal 60, client.timeout
    assert_equal 'ISO-8859-2', client.encoding
    assert client.debug
  end

  def test_przelewy24_instance_responds_to_client_methods
    client = Przelewy24.new(
      user: 'test_user',
      secret_id: 'test_secret',
      crc: 'test_crc'
    )

    assert_respond_to client, :transaction_register
    assert_respond_to client, :transaction_verify
    assert_respond_to client, :transaction_notification
    assert_respond_to client, :payment_methods
    assert_respond_to client, :test_access
    assert_respond_to client, :redirect_url
  end

  def test_redirect_url_returns_correct_format
    client = Przelewy24.new(
      user: 'test_user',
      secret_id: 'test_secret',
      crc: 'test_crc',
      base_url: 'https://sandbox.przelewy24.pl/api/v1'
    )

    token = 'ABC123XYZ'
    expected_url = 'https://sandbox.przelewy24.pl/trnRequest/ABC123XYZ'

    assert_equal expected_url, client.redirect_url(token)
  end
end
