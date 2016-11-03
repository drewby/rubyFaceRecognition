# Find Faces
# ----------
#
# This script uses the "geeks" facelist to identify faces in another photo. 
#
# The script has three parts. First, a call is made to the face detection API 
# which returns detected faces in this photo with FaceID. Second, a request
# is made to facelists API to get the list of known faces in the facelist "geeks".
# This is done to retrieve the userData containing the persons name who owns the face.
# Finally, each FaceID is sent to the Find Similars face API to compare against 
# known faces in facelist with ID geek. Found faces are written to the console.

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# Get your API key from https://www.microsoft.com/cognitive-services
apiKey = "<APIKEY>"
contentType = "application/json"
img_data = "{
    'url':'https://rubydrew.blob.core.windows.net/images/fishing.jpg'
}"
query = "?returnFaceId=true&returnFaceAttributes=age,gender,smile"
headers = {
  'Ocp-Apim-Subscription-Key' => apiKey,
  'Content-Type' => contentType
}

url = URI.parse("https://api.projectoxford.ai/face/v1.0/detect")
http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

# Detect the faces in the photo
resp = http.post(url.path + query, img_data, headers)

obj = JSON.parse(resp.body)

# Get the known faces in facelist "geeks""
url = URI.parse("https://api.projectoxford.ai/face/v1.0/facelists/geeks")
resp = http.get(url.path, headers)

geeks = JSON.parse(resp.body)

url = URI.parse("https://api.projectoxford.ai/face/v1.0/findsimilars")
obj.sort! { |a,b| a["faceRectangle"]["left"] <=> b["faceRectangle"]["left"] }

obj.each do |face|
    faceId = face["faceId"]
    post_data = "{    
        'faceId':'#{faceId}',
        'faceListId':'geeks',  
        'maxNumOfCandidatesReturned':10,
        'mode': 'matchPerson'
    }"

    # For each face detected, find similar faces in facelist.
    resp = http.post(url.path, post_data, headers)

    foundFace = JSON.parse(resp.body)
    
    if foundFace.length>0 then
        persistedFaceId = foundFace[0]["persistedFaceId"]
        confidence = foundFace[0]["confidence"]

        knownFace = geeks["persistedFaces"].select { |persistedFace| persistedFace["persistedFaceId"].eql?  persistedFaceId }           
        
        name = knownFace[0]["userData"]
        puts "Found #{name} with #{confidence} confidence"
    else
        puts "One person not recognized"
    end
end

