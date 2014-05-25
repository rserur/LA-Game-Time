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

  # Load raw CSV games array.
  @games = load_games

  # Create array for hashes of wins and losses by team.
  @team_stats = []

  # Grab all team names from games, whether the name is for
  # a home team or away team.
  @games.each do |game|
    # push each as the value of the key ":team"
    @team_stats.push({ team: (game[:home_team]) })
    @team_stats.push({ team: (game[:away_team]) })
  end

  # Condense to unique team names.
  @team_stats.uniq!

  # Loop through team hashes now stored in team_stats array.
  @team_stats.each do |team|

    #For each team, start new ":wins" and ":losses" key with values of 0.
    team[:wins] = 0
    team[:losses] = 0

    # For each team, look through games data.
    @games.each do |game|

      #If a game is found with the team playing at home...
      if game[:home_team] == team[:team]

        # and if the home team won, add a win.
        if game[:home_score].to_i > game[:away_score].to_i
          team[:wins] += 1

        # and if the home team lost, add a loss.
        else
          team[:losses] += 1
        end

      # If a game is found with the team playing away...
      elsif game[:away_team] == team[:team]

        # and if the away team won, add a win.
        if game[:away_score].to_i > game[:home_score].to_i
          team[:wins] += 1
        # and if the home team lost, add a loss.
        else
          team[:losses] += 1
        end

      end

    # End @games loop.
    end

  # End @team_stats loop.
  end

  # Sort team_stats by wins, highest to lowest...
  @team_stats = @team_stats.sort_by { |team| -team[:wins]}

  # then also by losses, lowest to highest.
  @team_stats = @team_stats.sort_by { |team| team[:losses]}


  # rank teams
  rank = 0

  @team_stats.each do |team|

    rank += 1
    team[:rank] = rank

  end

  erb :index

end

get '/teams/:team_name' do

  @games = load_games
  @team = {team: params[:team_name]}
  @team[:wins] = 0
  @team[:losses] = 0

  @games.each do |game|

      #If a game is found with the team playing at home...
      if game[:home_team] == @team[:team]

        # and if the home team won, add a win.
        if game[:home_score].to_i > game[:away_score].to_i
          @team[:wins] += 1

        # and if the home team lost, add a loss.
        else
          @team[:losses] += 1
        end

      # If a game is found with the team playing away...
      elsif game[:away_team] == @team[:team]

        # and if the away team won, add a win.
        if game[:away_score].to_i > game[:home_score].to_i
          @team[:wins] += 1
        # and if the home team lost, add a loss.
        else
          @team[:losses] += 1
        end

      end

    # End @games loop.
  end

  @games = @games.find_all do |game|
    game[:home_team] == @team[:team] ||
    game[:away_team] == @team[:team]
  end

  erb :team

end

