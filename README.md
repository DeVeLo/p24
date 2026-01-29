# P24

A Ruby gem for integrating with Przelewy24 (P24), a popular Polish payment gateway. This library provides a simple and intuitive interface for handling online payments through the Przelewy24 API v1.

## Features

- Transaction registration and verification
- Payment method discovery
- Transaction notification handling with signature verification
- Support for both sandbox and production environments
- Built-in authentication and request signing
- Comprehensive error handling

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'p24'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install p24
```

## Configuration

Initialize the client with your Przelewy24 credentials:

```ruby
client = P24::Client.new(
  user: 'your_merchant_id',
  secret_id: 'your_api_secret',
  crc: 'your_crc_key',
  base_url: 'https://sandbox.przelewy24.pl/api/v1', # Use production URL for live transactions
  timeout: 30,
  encoding: 'UTF-8',
  debug: false
)

# Alternatively, you can use the Przelewy24 alias
client = Przelewy24.new(
  user: 'your_merchant_id',
  secret_id: 'your_api_secret',
  crc: 'your_crc_key'
)
```

### Configuration Options

- `user` (required): Your Przelewy24 merchant ID
- `secret_id` (required): Your API secret/password
- `crc` (required): Your CRC key for request signing
- `base_url` (optional): API endpoint URL (defaults to sandbox)
- `timeout` (optional): Request timeout in seconds (default: 30)
- `encoding` (optional): Character encoding (default: 'UTF-8')
- `debug` (optional): Enable debug output (default: false)

## Usage

### Test API Access

Verify your credentials and API connectivity:

```ruby
response = client.test_access
puts response.error_code # Should be 0 for successful connection
```

### Register a Transaction

Create a new payment transaction:

```ruby
response = client.transaction_register(
  merchant_id: 12345,
  pos_id: 12345,
  session_id: 'unique_session_id',
  amount: 1000, # Amount in grosze (1000 = 10.00 PLN)
  currency: 'PLN',
  description: 'Order #123',
  email: 'customer@example.com',
  country: 'PL',
  language: 'pl',
  url_return: 'https://yoursite.com/payment/return',
  url_status: 'https://yoursite.com/payment/status'
)

# Get the payment token
token = response.token

# Redirect user to payment page
redirect_url = client.redirect_url(token)
# => "https://sandbox.przelewy24.pl/trnRequest/{token}"
```

### Verify a Transaction

Verify transaction status after payment:

```ruby
response = client.transaction_verify(
  merchant_id: 12345,
  pos_id: 12345,
  session_id: 'unique_session_id',
  amount: 1000,
  currency: 'PLN',
  order_id: 98765 # Received from P24 notification
)

puts response.error_code # 0 means successful verification
```

### Handle Payment Notifications

Verify incoming payment notifications from Przelewy24:

```ruby
# In your webhook/callback endpoint
is_valid = client.transaction_notification(
  merchant_id: params[:merchantId],
  pos_id: params[:posId],
  session_id: params[:sessionId],
  amount: params[:amount],
  origin_amount: params[:originAmount],
  currency: params[:currency],
  order_id: params[:orderId],
  method_id: params[:methodId],
  statement: params[:statement],
  sign: params[:sign]
)

if is_valid
  # Process successful payment
else
  # Invalid signature - potential fraud attempt
end
```

### Get Available Payment Methods

Retrieve available payment methods for your customers:

```ruby
methods = client.payment_methods(
  'pl', # Language
  amount: 1000, # Optional: filter by amount
  currency: 'PLN' # Optional: filter by currency
)

methods.each do |method|
  puts "#{method.name} - #{method.status}"
end
```

## API Reference

### Client Methods

#### `transaction_register(**kwargs)`
Registers a new transaction and returns a token for payment redirection.

#### `transaction_verify(**kwargs)`
Verifies a completed transaction.

#### `transaction_notification(**kwargs)`
Validates the signature of a payment notification from P24.

#### `payment_methods(lang, amount: nil, currency: nil)`
Retrieves available payment methods.

#### `test_access`
Tests API credentials and connectivity.

#### `redirect_url(token)`
Generates the payment page URL for a given token.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DeVeLo/p24.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Resources

- [Przelewy24 Official Documentation](https://docs.przelewy24.pl/)
- [Przelewy24 API v1 Reference](https://docs.przelewy24.pl/api-v1)
