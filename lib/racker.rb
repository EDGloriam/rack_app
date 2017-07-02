require './lib/actions'

class Racker
  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
    @request.session['start'] = true
    @actions = Actions.new(@request)
  end

  def response
    case @request.path
    when '/' then @actions.index
    when '/set_name' then @actions.set_name
    when '/new_game' then @actions.new_game
    when '/process_input' then @actions.process_input
    when '/hint' then @actions.hint
    else Rack::Response.new('Page Not Found', 404)
    end
  end
end
