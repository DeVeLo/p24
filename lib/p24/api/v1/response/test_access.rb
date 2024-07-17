# frozen_string_literal: true

module P24
  module Api
    module V1
      module Response
        class TestAccess
          attr_reader :data, :error

          def initialize(data:, error:)
            @data = data
            @error = error
          end

          def to_json(options = {})
            { data:, error: }.to_json(options)
          end

          class << self
            def from_json(json)
              new(
                data: json['data'],
                error: json['error']
              )
            end
          end
        end
      end
    end
  end
end
