# frozen_string_literal: true

require 'json'
require 'uri'
require 'httparty'
require 'digest'

require_relative 'p24/version'
require_relative 'p24/client'

require_relative 'przelewy24'

require_relative 'p24/api/v1/response/test_access'

require_relative 'p24/api/v1/request/transaction_register'

require_relative 'p24/api/v1/response/payment_methods'
require_relative 'p24/api/v1/response/payment_method/data'
require_relative 'p24/api/v1/response/payment_method/availability_hours'
require_relative 'p24/api/v1/response/transaction_register'

module P24
end
