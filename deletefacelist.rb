# Delete Face List
# ----------------
#
# This script deletes the facelist with ID "geeks". 

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# Get your API key from https://www.microsoft.com/cognitive-services
apiKey = "<APIKEY>"

headers = {
  'Ocp-Apim-Subscription-Key' => apiKey
}

url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

resp = http.delete(url.path, headers)

