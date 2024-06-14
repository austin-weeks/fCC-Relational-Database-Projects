#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams")

cat ./games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  #skipping column labels
  if [[ $YEAR = year ]]
  then
    continue
  fi
  #insert team fn takes in team_to_insert as $1
  insert_team () {
    #get team_id from teams
    team_id_to_insert=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
    #if it does not exist
    if [[ -z $team_id_to_insert ]]
    then
      #add team to teams
      insert_team_result=$($PSQL "INSERT INTO teams (name) VALUES ('$1')")
      if [[ $insert_team_result = "INSERT 0 1" ]]
      then 
        echo Inserted into teams: $1
      fi
    fi
  }
  #winners
  insert_team "$WINNER"
  #opponents
  insert_team "$OPPONENT"

  #get team_id for opponent and winner from teams table
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  #add game info using winner and opponent ids
  insert_game_result=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $winner_id, $opponent_id, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $insert_game_result = "INSERT 0 1" ]]
  then
    echo Inserted into games: $WINNER v. $OPPONENT, $YEAR
  fi
done