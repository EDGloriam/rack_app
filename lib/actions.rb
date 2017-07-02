require 'erb'
require 'codebreaker'
require './lib/session'

class Actions
  attr_accessor :player

  def initialize(request)
    @request = request
    @sessions_helper = SessionHelper.new
    @session_id = @request.session['session_id'].to_sym
    @session = @sessions_helper.open_session(@session_id)
    @game = @session[:game]
    @curent_game = @session[:curent_game] || []
    @hint = @session[:hint]
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
    @game.attempts_left = 10
    @curent_game = []
    @sessions_helper.save_set_params(@session_id,  %i(game curent_game), [@game, @curent_game])
    Rack::Response.new(render('main'))
  end

  def process_input
    user_input = @request.params['user_input']
    result = @game.reply(user_input)
    result = 'no coincidence' if result.empty?
    store(user_input, result)
    return break_game(result) if [:won, :lose].include? result
    Rack::Response.new(render('show_reply'))
  end

  def break_game(game_result)
    File.truncate('./sessions/sessions.yml', 0)
    Rack::Response.new(render(game_result))
  end

  def hint
    hint = before_hint
    @sessions_helper.save_to_yml(@session_id, :hint, hint) if hint
    @hint = @session[:hint]
    Rack::Response.new(render('show_reply'))
  end

  def before_hint
    hint = @game.reply('hint')
    return hint unless hint == 'no hint'
    false
  end

  def store(user_input, result)
    @curent_game.push(user_input: user_input, result: result)
    @sessions_helper.save_set_params(@session_id, %i(game curent_game ), [@game, @curent_game])
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
