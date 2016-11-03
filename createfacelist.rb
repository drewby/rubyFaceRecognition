# Create Face List
# ----------------
#
# This script will create a facelist containing the faces in the three geeks photo. 
# The face list can be used to then match faces in other photos. 
# 
# There are four steps to the script. First, a face detection call is made to 
# determine location of faces in the photo. Second, a call is made to create
# the facelist with ID "geeks". Third, for each face, a call is made to Added
# the face to the facelist, using the photo coordinates from the earlier detection
# call. Finally, a request is made to retrieve the facelist to output the
# result to the console.

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# Get your API key from https://www.microsoft.com/cognitive-services
apiKey = "<APIKEY>"
contentType = "application/json"
img_data = "{
    'url':'https://rubydrew.blob.core.windows.net/images/threegeeks.jpg'
}"
query = "?returnFaceId=true&returnFaceAttributes=age,gender,smile"
headers = {
  'Ocp-Apim-Subscription-Key' => apiKey,
  'Content-Type' => contentType
}

url = URI.parse("https://api.projectoxford.ai/face/v1.0/detect")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

# Call to face detection API to locate faces in the photo. 
resp = http.post(url.path + query, img_data, headers)
detectedFaces = JSON.parse(resp.body)

url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks")
post_data = "{
  'name':'geeks',
  'userData':'Three geek faces. Be Lazy!'
}"

# Call to facelist API to create facelist with ID "geeks"
resp = http.put(url.path + query, post_data, headers)

url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks/persistedFaces")
detectedFaces.sort! { |a,b| a["faceRectangle"]["left"] <=> b["faceRectangle"]["left"] }

# Assuming three faces from known photo detected, sorted left to right. 
detectedFaces[0]["name"] = "Drew"
detectedFaces[1]["name"] = "Matz"
detectedFaces[2]["name"] = "Daisuke"

detectedFaces.each do |face|
  faceRectangle = face["faceRectangle"]
  left = faceRectangle["left"]
  top = faceRectangle["top"]
  width = faceRectangle["width"]
  height = faceRectangle["height"]
  name = face["name"]

  query = "?userData=#{name}&targetFace=#{left},#{top},#{width},#{height}"
  
  # Call to facelist API to add this face to the facelist "geeks"
  resp = http.post(url.path + query, img_data, headers)

  faceAttributes = face["faceAttributes"]
  age = faceAttributes["age"]
  gender = faceAttributes["gender"]
  smile = faceAttributes["smile"]
  puts "Added #{gender} #{name} who appears #{age} and is smiling #{smile}"
end

# Get the facelist and display to console
url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks")
resp = http.get(url.path, headers)

puts resp.body


