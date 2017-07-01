require 'erb'
require 'codebreaker'
require './lib/actions'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    puts "initialize works I N I T I A L I Z E"
    @request = Rack::Request.new(env)
    @request.session['start'] = true
    @actions = Actions.new(@request)
  end

  def response
    case @request.path
    when '/' then  @actions.index
    when '/set_name' then  @actions.set_name
    when '/game' then @actions.game
    when '/process_reply' then @actions.process_reply
    when '/hint' then @actions.hint
    else Rack::Response.new('Page Not Found', 404)
    end
  end


  # def word
  #   @request.cookies['word'] || 'Nothing'
  # end
end