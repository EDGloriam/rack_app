require './lib/racker'
# app = Rack::Builder.new do
  use Rack::Static, urls: ['/style', '/img', '/js'], root: 'public'
  use Rack::Session::Cookie,  key: 'edg-rack',
                            expire_after: 2592000,
                            secret: 'secret-codebreaker'
  run Racker
# end

# run app