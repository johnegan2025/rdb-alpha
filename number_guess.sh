#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read -r USERNAME

# Get existing user information
USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."

  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')" > /dev/null
else
  GAMES_PLAYED=$(echo "$USER_INFO" | cut -d'|' -f1)
  BEST_GAME=$(echo "$USER_INFO" | cut -d'|' -f2)

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while true
do
  if ! [[ $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES + 1))

  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done

# Update user statistics
$PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'" > /dev/null

# Update best game if this was the user's first game or their new best
$PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME' AND (best_game IS NULL OR $NUMBER_OF_GUESSES < best_game)" > /dev/null