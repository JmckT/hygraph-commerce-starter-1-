# server.rb
#
# Use this sample code to handle webhook events in your integration.
#
# 1) Paste this code into a new file (server.rb)
#
# 2) Install dependencies
#   gem install sinatra
#   gem install stripe
#
# 3) Run the server on http://localhost:4242
#   ruby server.rb

require 'json'
require 'sinatra'
require 'stripe'

# This is your Stripe CLI webhook secret for testing your endpoint locally.
endpoint_secret = 'whsec_19433a669ce03152548cf6763156df6efe6439cd6f2bc14d5da17377bfbaa60b'

set :port, 4242

post '/webhook' do
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
        event = Stripe::Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
    rescue JSON::ParserError => e
        # Invalid payload
        status 400
        return
    rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        status 400
        return
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
        session = event.data.object
    when 'order.created'
        order = event.data.object
    # ... handle other event types
    else
        puts "Unhandled event type: #{event.type}"
    end

    status 200
end
