#!/bin/bash

psql="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

random_number=$((1 + $RANDOM % 1000))
guesses=0

guess () {
  read user_input
  if [[ ! $user_input =~ ^[0-9]+$ ]]; then
    echo That is not an integer, guess again:
    guess
    return
  fi

  guesses=$(($guesses + 1))

  if [[ $user_input -lt $random_number ]]; then
    echo It\'s higher than that, guess again:
    guess
    return
  elif [[ $user_input -gt $random_number ]]; then
    echo It\'s lower than that, guess again:
    guess
    return
  else
    echo You guessed it in $guesses tries. The secret number was $random_number. Nice job!
  fi
}


echo -e "\n---- Number Guessing Game ----\n"
echo Enter your username:
read input_username
echo 

get_username () {
  echo $($psql "SELECT username FROM users WHERE username = '$input_username'")
}

username=$(get_username)

if [[ -z $username ]]; then
  add_username=$($psql "INSERT INTO users (username) VALUES ('$input_username')")
  username=$(get_username)
  echo Welcome, $username! It looks like this is your first time here.
else
  games_played=$($psql "SELECT games FROM users WHERE username = '$username'")
  best_game=$($psql "SELECT best_game FROM users WHERE username = '$username'")
  echo Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses.
fi

echo Guess the secret number between 1 and 1000:
guess
new_games_played=$(($games_played + 1))
update_games_played=$($psql "UPDATE users SET games = $new_games_played WHERE username = '$username'")
if [[ $best_game -gt $guesses || -z $best_game ]]; then
  update_best_game=$($psql "UPDATE users SET best_game = $guesses WHERE username = '$username'")
fi
