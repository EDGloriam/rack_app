require 'erb'
require 'codebreaker'
require './lib/session'

class Actions
  attr_accessor :player

  def initialize(request)
    puts "Action INITIALIZE"
    @request = request
      @sessions_helper = SessionHelper.new
      @session_id = @request.session['session_id'].to_sym
      @session = @sessions_helper.open_session(@session_id)
    @game = @session[:game]
    @curent_game = @session[:curent_game] || []
    @hint = false
  end

  def index
    Rack::Response.new(render('set_name'))
  end

  def set_name
    @player = @request.params['name']
    @sessions_helper.save_to_yml(@session_id, :player, @player)
    redirect('new_game')
  end

  def new_game
    @session[:game] = Codebreaker::Game.new
    @game.attempts_left = 10
    @curent_game = []
    @sessions_helper.save_set_params(@session_id,
      %i(game curent_game),
      [@game, @curent_game])
    Rack::Response.new(render('main'))
  end

  def process_input
    user_input = @request.params['user_input']
    result = @game.reply(user_input)
    store(user_input, result)
    return Rack::Response.new(render('lose')) if result == :lose
    return Rack::Response.new(render('won')) if result == :won
    Rack::Response.new(render('show_reply'))
  end

  def hint
    result = @game.reply('hint')
    @hint = result unless result == 'no hint'
    Rack::Response.new(render('show_reply'))
  end

  def store(user_input, result)
    @curent_game.push(user_input: user_input, result: result)
    @sessions_helper.save_set_params(@session_id,
      %i(game curent_game ),
      [@game, @curent_game])
  end

  def render(template)
    templates = [template, 'app_layout']
    templates.inject(nil) do |piece, main_template|
      _render(main_template) { piece }
    end
  end


  def _render(template)
    path = File.expand_path("./views/#{template}.html.erb")
    ERB.new(File.read(path)).result(binding)
  end

  def redirect(url)
    Rack::Response.new do |response|
      response.redirect(url)
    end
  end
end
