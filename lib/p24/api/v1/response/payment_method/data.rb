# frozen_string_literal: true

module P24
  module Api
    module V1
      module Response
        module PaymentMethod
          class Data
            attr_reader :name, :id, :group, :subgroup, :status, :img_url,
                        :mobile_img_url, :mobile, :availability_hours

            def initialize(name:, id:, group:, subgroup:, status:, img_url:,
                           mobile_img_url:, mobile:, availability_hours:)
              @name = name
              @id = id
              @group = group
              @subgroup = subgroup
              @status = status
              @img_url = img_url
              @mobile_img_url = mobile_img_url
              @mobile = mobile
              @availability_hours = AvailabilityHours.from_json(availability_hours)
            end

            def to_json(options = {})
              { name:, id:, group:, subgroup:, status:, img_url:,
                mobile_img_url:, mobile:, availability_hours: }.to_json(options)
            end

            class << self
              def from_json(json)
                new(
                  name: json['name'],
                  id: json['id'],
                  group: json['group'],
                  subgroup: json['subgroup'],
                  status: json['status'],
                  img_url: json['imgUrl'],
                  mobile_img_url: json['mobileImgUrl'],
                  mobile: json['mobile'],
                  availability_hours: json['availabilityHours']
                )
              end
            end
          end
        end
      end
    end
  end
end
