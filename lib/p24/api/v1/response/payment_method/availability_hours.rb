# frozen_string_literal: true

module P24
  module Api
    module V1
      module Response
        module PaymentMethod
          class AvailabilityHours
            attr_reader :monday_to_friday, :saturday, :sunday

            def initialize(monday_to_friday:, saturday:, sunday:)
              @monday_to_friday = monday_to_friday
              @saturday = saturday
              @sunday = sunday
            end

            def to_json(options = {})
              { monday_to_friday:, saturday:, sunday: }.to_json(options)
            end

            class << self
              def from_json(json)
                new(
                  monday_to_friday: json['mondayToFriday'],
                  saturday: json['saturday'],
                  sunday: json['sunday']
                )
              end
            end
          end
        end
      end
    end
  end
end
