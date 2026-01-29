# frozen_string_literal: true

module P24
  module Api
    module V1
      module Response
        class TransactionRegister
          attr_reader :data, :response_code

          Data = Struct.new(:token)

          def initialize(data:, response_code:)
            @data = Data.new(data['token'])
            @response_code = response_code
          end

          def to_json(options = {})
            { data: data.to_h, response_code: }.to_json(options)
          end

          class << self
            def from_json(json)
              new(
                data: json['data'],
                response_code: json['responseCode']
              )
            end
          end
        end
      end
    end
  end
end
