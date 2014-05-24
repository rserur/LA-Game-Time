require 'sinatra'
require 'csv'

def load_games

  games = []

  CSV.foreach('games.csv', headers: true, header_converters: :symbol) do |row|
    games << row.to_hash
  end

  games

end

get '/leaderboard' do

  @games = load_games
  @all_teams = []

  @games.each do |game|
    @all_teams.push(game[:home_team])
    @all_teams.push(game[:away_team])
  end

  @all_teams.uniq!

  erb :index

end

