# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'digest'

class TestClient < Minitest::Test
  def setup
    @user = 'test_user'
    @secret_id = 'test_secret'
    @crc = 'test_crc'
  end

  def test_initialization_with_required_parameters
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)

    assert_equal @user, client.user
    assert_equal @secret_id, client.secret_id
    assert_equal @crc, client.crc
  end

  def test_initialization_with_default_values
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)

    assert_equal 'https://sandbox.przelewy24.pl/api/v1', client.base_url
    assert_equal 30, client.timeout
    assert_equal 'UTF-8', client.encoding
    refute client.debug
  end

  def test_initialization_with_custom_values
    custom_url = 'https://secure.przelewy24.pl/api/v1'
    custom_timeout = 60
    custom_encoding = 'ISO-8859-2'

    client = P24::Client.new(
      user: @user,
      secret_id: @secret_id,
      crc: @crc,
      base_url: custom_url,
      timeout: custom_timeout,
      encoding: custom_encoding,
      debug: true
    )

    assert_equal custom_url, client.base_url
    assert_equal custom_timeout, client.timeout
    assert_equal custom_encoding, client.encoding
    assert client.debug
  end

  def test_redirect_url_with_token
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    token = 'abc123def456'

    url = client.redirect_url(token)

    assert_equal 'https://sandbox.przelewy24.pl/trnRequest/abc123def456', url
  end

  def test_redirect_url_with_production_base_url
    client = P24::Client.new(
      user: @user,
      secret_id: @secret_id,
      crc: @crc,
      base_url: 'https://secure.przelewy24.pl/api/v1'
    )
    token = 'xyz789'

    url = client.redirect_url(token)

    assert_equal 'https://secure.przelewy24.pl/trnRequest/xyz789', url
  end

  def test_transaction_notification_delegates_to_transaction_notification_class
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    notification_params = {
      merchant_id: 12_345,
      pos_id: 67_890,
      session_id: 'test_session',
      amount: 1000,
      origin_amount: 900,
      currency: 'PLN',
      order_id: 999,
      method_id: 25,
      statement: 'Test',
      sign: 'valid_sign'
    }

    sign_params = {
      merchantId: notification_params[:merchant_id],
      posId: notification_params[:pos_id],
      sessionId: notification_params[:session_id],
      amount: notification_params[:amount],
      originAmount: notification_params[:origin_amount],
      currency: notification_params[:currency],
      orderId: notification_params[:order_id],
      methodId: notification_params[:method_id],
      statement: notification_params[:statement],
      crc: @crc
    }
    valid_sign = Digest::SHA384.hexdigest(sign_params.to_json)
    notification_params[:sign] = valid_sign

    result = client.transaction_notification(**notification_params)

    assert result
  end

  def test_test_access_successful_response
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    response_body = { 'data' => { 'token' => 'test123' }, 'error' => nil }.to_json
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, true
    mock_response.expect :body, response_body

    HTTParty.stub :get, mock_response do
      result = client.test_access

      assert_equal({ 'token' => 'test123' }, result.data)
      assert_nil result.error
    end

    mock_response.verify
  end

  def test_test_access_raises_error_on_failure
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, false
    mock_response.expect :code, 401
    mock_response.expect :body, 'Unauthorized'

    HTTParty.stub :get, mock_response do
      error = assert_raises(RuntimeError) do
        client.test_access
      end

      assert_match(/Invalid HTTP response code: 401/, error.message)
      assert_match(/Unauthorized/, error.message)
    end

    mock_response.verify
  end

  def test_payment_methods_successful_response
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    payment_method_data = {
      'name' => 'Card',
      'id' => 1,
      'group' => 'cards',
      'subgroup' => 'visa',
      'status' => 'active',
      'imgUrl' => 'https://example.com/card.png',
      'mobileImgUrl' => 'https://example.com/card-mobile.png',
      'mobile' => true,
      'availabilityHours' => {}
    }
    response_body = {
      'data' => [payment_method_data],
      'agreements' => [],
      'responseCode' => 0
    }.to_json
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, true
    mock_response.expect :body, response_body

    HTTParty.stub :get, mock_response do
      result = client.payment_methods('pl')

      assert_instance_of P24::Api::V1::Response::PaymentMethods, result
      assert_equal 1, result.data.length
      assert_equal 1, result.data.first.id
      assert_equal 'Card', result.data.first.name
    end

    mock_response.verify
  end

  def test_payment_methods_with_optional_parameters
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    payment_method_data = {
      'name' => 'Card',
      'id' => 1,
      'group' => 'cards',
      'subgroup' => 'visa',
      'status' => 'active',
      'imgUrl' => 'https://example.com/card.png',
      'mobileImgUrl' => 'https://example.com/card-mobile.png',
      'mobile' => true,
      'availabilityHours' => {}
    }
    response_body = {
      'data' => [payment_method_data],
      'agreements' => [],
      'responseCode' => 0
    }.to_json
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, true
    mock_response.expect :body, response_body

    HTTParty.stub :get, mock_response do
      result = client.payment_methods('pl', amount: 1000, currency: 'PLN')

      assert_instance_of P24::Api::V1::Response::PaymentMethods, result
      assert_equal 1, result.data.length
    end

    mock_response.verify
  end

  def test_transaction_register_successful_response
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    response_body = { 'data' => { 'token' => 'test_token_123' }, 'responseCode' => 0 }.to_json
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, true
    mock_response.expect :body, response_body

    HTTParty.stub :post, mock_response do
      result = client.transaction_register(
        merchant_id: 12_345,
        pos_id: 67_890,
        session_id: 'test_session',
        amount: 1000,
        currency: 'PLN',
        description: 'Test transaction',
        email: 'test@example.com',
        country: 'PL',
        language: 'pl',
        url_return: 'https://example.com/return'
      )

      assert_instance_of P24::Api::V1::Response::TransactionRegister, result
      assert_equal 0, result.response_code
    end

    mock_response.verify
  end

  def test_transaction_verify_successful_response
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    response_body = { 'data' => { 'status' => 'success' }, 'responseCode' => 0 }.to_json
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, true
    mock_response.expect :body, response_body

    HTTParty.stub :put, mock_response do
      result = client.transaction_verify(
        merchant_id: 12_345,
        pos_id: 67_890,
        session_id: 'test_session',
        amount: 1000,
        currency: 'PLN',
        order_id: 999
      )

      assert_instance_of P24::Api::V1::Response::TransactionVerify, result
      assert_equal 0, result.response_code
    end

    mock_response.verify
  end

  def test_transaction_register_raises_error_on_failure
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, false
    mock_response.expect :code, 400
    mock_response.expect :body, 'Bad Request'

    HTTParty.stub :post, mock_response do
      error = assert_raises(RuntimeError) do
        client.transaction_register(
          merchant_id: 12_345,
          pos_id: 67_890,
          session_id: 'test_session',
          amount: 1000,
          currency: 'PLN',
          description: 'Test transaction',
          email: 'test@example.com',
          country: 'PL',
          language: 'pl',
          url_return: 'https://example.com/return'
        )
      end

      assert_match(/Invalid HTTP response code: 400/, error.message)
      assert_match(/Bad Request/, error.message)
    end

    mock_response.verify
  end

  def test_transaction_verify_raises_error_on_failure
    client = P24::Client.new(user: @user, secret_id: @secret_id, crc: @crc)
    mock_response = Minitest::Mock.new
    mock_response.expect :success?, false
    mock_response.expect :code, 404
    mock_response.expect :body, 'Transaction not found'

    HTTParty.stub :put, mock_response do
      error = assert_raises(RuntimeError) do
        client.transaction_verify(
          merchant_id: 12_345,
          pos_id: 67_890,
          session_id: 'test_session',
          amount: 1000,
          currency: 'PLN',
          order_id: 999
        )
      end

      assert_match(/Invalid HTTP response code: 404/, error.message)
      assert_match(/Transaction not found/, error.message)
    end

    mock_response.verify
  end
end
