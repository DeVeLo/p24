# frozen_string_literal: true

module P24
  class Client
    attr_reader :user, :secret_id, :crc, :base_url, :timeout

    def initialize(user:, secret_id:, crc:, base_url: 'https://sandbox.przelewy24.pl/api/v1', timeout: 30)
      @user = user
      @secret_id = secret_id
      @crc = crc
      @timeout = timeout
      @base_url = base_url
    end

    def transaction_register(**kwargs)
      generic_post_json(
        endpoint('/transaction/register'),
        Api::V1::Request::TransactionRegister.new(**kwargs.merge({ crc: })).to_json,
        Api::V1::Response::TransactionRegister
      )
    end

    def transaction_verify(**kwargs)
      generic_put_json(
        endpoint('/transaction/verify'),
        Api::V1::Request::TransactionVerify.new(**kwargs.merge({ crc: })).to_json,
        Api::V1::Response::TransactionVerify
      )
    end

    def transaction_notification(json)
      Api::V1::TransactionNotification.from_json(json, crc).correct?
    end

    def payment_methods(lang, amount: nil, currency: nil)
      generic_json endpoint(
        "/payment/methods/#{lang}",
        **keyword_args(__method__, binding)
      ), Api::V1::Response::PaymentMethods
    end

    def test_access
      generic_json endpoint(
        '/testAccess'
      ), Api::V1::Response::TestAccess
    end

    private

    def endpoint(url, *_args, **params)
      uri = URI "#{base_url}#{url}"
      uri.query = URI.encode_www_form(convert_keys_to_camelcase(params)).gsub('%2C', ',')
      uri.to_s
    end

    def generic_json(uri, type)
      response = HTTParty.get(uri, timeout:, basic_auth:, headers:)
      handle_response(uri, response, type)
    end

    def generic_post_json(uri, body, type)
      response = HTTParty.put(uri, timeout:, basic_auth:, headers:, body:)
      handle_response(uri, response, type)
    end

    def generic_post_json(uri, body, type)
      response = HTTParty.post(uri, timeout:, basic_auth:, headers:, body:)
      handle_response(uri, response, type)
    end

    def handle_response(uri, response, type)
      if response.success?
        json_response = JSON.parse(response.body)
        response_container = json_response.is_a?(Array) ? json_response : json_response['response']
        if response_container.is_a?(Array)
          response_container.map do |response_json|
            type.from_json(response_json)
          end
        else
          type.from_json(json_response)
        end
      else
        raise_error(response, uri)
      end
    end

    def raise_error(response, uri)
      raise "Invalid HTTP response code: #{response.code}; " \
            "Response body: #{response.body}; " \
            "Request URI: #{uri};"
    end

    def convert_keys_to_camelcase(hash)
      hash.transform_keys { |key| camelcase(key.to_s) }
    end

    def basic_auth
      { username: user, password: secret_id }
    end

    def headers
      { 'Content-Type' => 'application/json' }
    end

    def pids(array)
      return if array.count.zero?

      array.join(',')
    end

    def handle_args(arg)
      case arg
      when Array
        pids(arg)
      else
        arg
      end
    end

    def camelcase(str)
      str.split('_').inject([]) { |buffer, e| buffer.push(buffer.empty? ? e : e.capitalize) }.join
    end

    def keyword_args(meth, bind)
      method(meth).parameters.select { |type, _| %i[key keyreq].include? type }.map do |_, name|
        [name, handle_args(bind.local_variable_get(name))]
      end.to_h.compact
    end
  end
end
