require 'net/http'
require 'net/https'
require 'uri'
require 'json'

apiKey = "<APIKEY>"
contentType = "application/json"
img_data = "{
    'url':'https://rubydrew.blob.core.windows.net/images/fishing.jpg'
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

