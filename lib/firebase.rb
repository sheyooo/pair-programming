require 'firebase'
base_uri = 'https://pair-pro.firebaseio.com/'

firebase = Firebase::Client.new(base_uri)

response = firebase.push('todos', name: 'Pick the milk', priority: 1)
response.success? # => true
response.code # => 200
response.body # => { 'name' => "-INOQPH-aV_psbk3ZXEX" }
response.raw_body # => '{"name":"-INOQPH-aV_psbk3ZXEX"}'

puts response.raw_body
