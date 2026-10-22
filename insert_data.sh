#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#remove existing data

#Script to insert data from games.csv into worldcup database
echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

#Insert data from games.csv to teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
if [[ $YEAR != year ]]
then
#get team_id
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' OR name='$OPPONENT'")
#if not found
if [[ -z $TEAM_ID ]]
then
#set to null
TEAM_ID=null
fi
#insert winner teams
INSERT_WINNER_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING")
#insert opponent teams
INSERT_OPPONENT_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING")
if [[ $INSERT_WINNER_NAME == "INSERT 0 1" ]]
then
[[ $INSERT_OPPONENT_NAME == "INSERT 0 1" ]]
fi
fi
done
TEAM_COUNT=$($PSQL "SELECT COUNT(*) FROM teams")
echo Inserted $TEAM_COUNT records into teams

#insert games.csv into games table

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
#set winner_id and opponent_id variables
WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
if [[ $YEAR != year ]]
then
#get game_id
GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR")
#if not found
if [[ -z $GAME_ID ]]
then
#set to null
GAME_ID=null
fi
#insert games data
GAME_INPUT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER, $OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")
if [[ -n $YEAR ]]
then
[[ $GAME_INPUT == "INSERT 0 1" ]]
fi
fi
done
GAME_COUNT=$($PSQL "SELECT COUNT(*) FROM games")
echo Inserted $GAME_COUNT records into games