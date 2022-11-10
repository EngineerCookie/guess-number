#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "================================="
echo "FOR TESTING: the secret number is $SECRET_NUMBER"
echo "TESTING CONSISTENCY: $SECRET_NUMBER"
echo "================================="

#LOGIN
echo "Enter your username:"
read USERNAME
#check database
USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")
#if new player
if [[ -z $USER_ID ]]
  then
  REGISTER_USER=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")
  #USER_PLAY_COUNT=$($PSQL "UPDATE players SET games_played=games_played+1 WHERE user_id=$USER_ID")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
#if returning player
else
  USERNAME=$($PSQL "SELECT username FROM players WHERE user_id=$USER_ID")
  USER_PLAYED=$($PSQL "SELECT games_played FROM players WHERE user_id=$USER_ID")
  #USER_PLAY_COUNT=$($PSQL "UPDATE players SET games_played=games_played+1 WHERE user_id=$USER_ID")
  USER_BEST=$($PSQL "SELECT best_game FROM players WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $USER_PLAYED games, and your best game took $USER_BEST guesses."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS
COUNT=1
#COUNT=$(( COUNT + 1 ))
while [[ ! $GUESS -eq $SECRET_NUMBER ]] 
do
#check integere
if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
  echo "That is not an integer, guess again:"
  read GUESS
else
#check value
if [[ $GUESS -gt $SECRET_NUMBER ]]
  then
  COUNT=$(( COUNT +1 ))
  echo "It's lower than that, guess again:"
  read GUESS
else
  COUNT=$(( COUNT +1 ))
  echo "It's higher than that, guess again:"
  read GUESS
fi
fi
done
echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
USER_PLAY_COUNT=$($PSQL "UPDATE players SET games_played=games_played+1 WHERE user_id=$USER_ID")

#best game update
if [[ $USER_BEST -eq 0 || $USER_BEST -gt $COUNT ]]
then
BEST_SCORE_UPDATE=$($PSQL "UPDATE players SET best_game=$COUNT WHERE user_id=$USER_ID")
fi
#echo "~~end of script~~"