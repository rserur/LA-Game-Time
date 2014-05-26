require 'sinatra'
require 'csv'

# A method to load CSV into array.
def load_games

  games = []

  CSV.foreach('games.csv', headers: true, header_converters: :symbol) do |row|

    games << row.to_hash

  end

  games

end

# A method to look through games for specified team's wins and losses.
def get_stats(games, team)

  team[:wins] = 0
  team[:losses] = 0

  games.each do |game|

    #Wins and losses if a game is found with the team playing at home...
    if game[:home_team] == team[:team]

      game[:home_score].to_i > game[:away_score].to_i ? team[:wins] += 1 : team[:losses] += 1

      # or if a game is found with the team playing away.
    elsif game[:away_team] == team[:team]

      game[:away_score].to_i > game[:home_score].to_i ? team[:wins] += 1 : team[:losses] += 1

    end

  end

end

# Generate leaderboard.
get '/leaderboard' do

  # Load games array from CSV.
  @games = load_games

  # Create array for hashes of wins and losses by team.
  @team_stats = []

  # Grab all team names from games.
  @games.each do |game|

    @team_stats.push({ team: (game[:home_team]) })
    @team_stats.push({ team: (game[:away_team]) })

  end

  # Condense to unique team names.
  @team_stats.uniq!

  # Loop through team hashes now stored in team_stats array.
  @team_stats.each do |team|

    # Fill team's hash with wins and losses.
    get_stats(@games, team)

  end

  # Sort team_stats by wins, highest to lowest...
  @team_stats = @team_stats.sort_by { |team| -team[:wins]}

  # then also by losses, lowest to highest.
  @team_stats = @team_stats.sort_by { |team| team[:losses]}

  # Rank teams.
  ranks = 0

  @team_stats.each do |team|

    ranks += 1
    team[:rank] = ranks

  end

  erb :index

end

get '/teams/:team_name' do

  @games = load_games
  @team = {team: params[:team_name]}

  get_stats(@games, @team)

  # Find all games the team played.
  @games = @games.find_all do |game|

    game[:home_team] == @team[:team] || game[:away_team] == @team[:team]

  end

  erb :team

end

# Make the leaderboard the index page.
get '/' do

  redirect '/leaderboard'

end
