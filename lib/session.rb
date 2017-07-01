require 'yaml'
require 'codebreaker'

class SessionHelper
  def initialize
    @session = YAML.load(File.open('./sessions/sessions.yml')) || {}
  end

  def open_session(id)
    if !@session[id] || !@session[id][:game]
      @session[id] = { game: Codebreaker::Game.new }
      File.open('./sessions/sessions.yml', 'w') { |f| f.write(@session.to_yaml) }
    end
    @session[id]
  end

  def save_to_yml(id, key, value)
    @session[id][key] = value
    File.open('./sessions/sessions.yml', 'w') { |f| f.write(@session.to_yaml) }
  end

  def save_set_params(id, keys, values)
    keys.each_with_index { |key, index| save_to_yml(id, key, values[index])}
  end
end