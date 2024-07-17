# frozen_string_literal: true

module P24
  module Api
    module V1
      module Response
        class PaymentMethods
          attr_reader :data, :agreements, :response_code

          def initialize(data:, agreements:, response_code:)
            @data = data.map { |d| PaymentMethod::Data.from_json(d) }
            @agreements = agreements
            @response_code = response_code
          end

          def to_json(options = {})
            { data:, agreements:, response_code: }.to_json(options)
          end

          class << self
            def from_json(json)
              new(
                data: json['data'],
                agreements: json['agreements'],
                response_code: json['responseCode']
              )
            end
          end
        end
      end
    end
  end
end
