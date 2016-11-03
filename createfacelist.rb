require 'net/http'
require 'net/https'
require 'uri'
require 'json'

apiKey = "<APIKEY>"
contentType = "application/json"
img_data = "{
    'url':'https://rubydrew.blob.core.windows.net/images/threegeeks.jpg'
}"
query = "?returnFaceId=true&returnFaceAttributes=age,gender,smile"

url = URI.parse("https://api.projectoxford.ai/face/v1.0/detect")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

headers = {
  'Ocp-Apim-Subscription-Key' => apiKey,
  'Content-Type' => contentType
}

resp = http.post(url.path + query, img_data, headers)

obj = JSON.parse(resp.body)

url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks")
post_data = "{
  'name':'geeks',
  'userData':'Three geek faces. Be Lazy!'
}"

resp = http.put(url.path + query, post_data, headers)

url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks/persistedFaces")
obj.sort! { |a,b| a["faceRectangle"]["left"] <=> b["faceRectangle"]["left"] }

obj[0]["name"] = "Drew"
obj[1]["name"] = "Matz"
obj[2]["name"] = "Daisuke"

obj.each do |face|
  faceRectangle = face["faceRectangle"]
  left = faceRectangle["left"]
  top = faceRectangle["top"]
  width = faceRectangle["width"]
  height = faceRectangle["height"]
  name = face["name"]

  query = "?userData=#{name}&targetFace=#{left},#{top},#{width},#{height}"
  
  resp = http.post(url.path + query, img_data, headers)

  faceAttributes = face["faceAttributes"]
  age = faceAttributes["age"]
  gender = faceAttributes["gender"]
  smile = faceAttributes["smile"]
  puts "Added #{gender} #{name} who appears #{age} and is smiling #{smile}"
end

url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks")
resp = http.get(url.path, headers)

puts resp.body


