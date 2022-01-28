#!/usr/bin/env bash
#
# A script that takes a Twitter data archive, which is produced as a
# set of JavaScript files (different from the regular archive, which
# is CSV and HTML), and converts the `tweet.js` file, which contains
# all of the tweets, into tractable JSON, one tweet per line. It then
# inserts /that/ into a SQLite3 database, and extracts a simple
# relational table of tweets from the JSON. Finally, it runs datasette
# on the resulting database to allow you to explore.
#
# requires:
# - `jq`: https://stedolan.github.io/jq/
# - `datasette`: https://github.com/simonw/datasette
# optional:
# - `pv`: http://www.ivarch.com/programs/pv.shtml
#

# where you unzipped your data archive
DIR=./twitterarchive

# the name of your sqlite database
DB=t.db

CONCATENATOR=$(command -v pv || command -v cat)

if test -f $DB; then
    rm $DB
fi

echo "### Loading Data..."

# Start our parens....
(
    echo """
CREATE TABLE IF NOT EXISTS source (name TEXT, js JSON);
CREATE TABLE IF NOT EXISTS tweets
  (full_text TEXT,
   rts INTEGER,
   favs INTEGER);
BEGIN TRANSACTION;
"""

    $CONCATENATOR $DIR/tweet.js |
        sed 's/^window.*=//' |
        jq '.[]' -c |
        sed "s/'/''/g" |
        sed -re "s/(.*)/INSERT INTO SOURCE (name, js) VALUES ('tweet', '\\1');/"

    echo """
END TRANSACTION;
INSERT INTO tweets
  SELECT
    JSON_EXTRACT(js, '$.full_text') AS full_text,
    JSON_EXTRACT(js, '$.retweet_count') AS rts,
    JSON_EXTRACT(js, '$.favorite_count') AS favs
    FROM source;
"""
) |
    sqlite3 $DB
# ########################################
# note that we wrapped the above
# in parens and fed that to sqlite3.
# ########################################

echo """### Here is your URL

http://localhost:8001/t?sql=select+favs%2Frts+as+the_ratio%2C+rts%2C+favs%2C+full_text+%0D%0Afrom+tweets+%0D%0Aorder+by+the_ratio+desc+%0D%0Alimit+101

### Datasette is starting...
"""

datasette $DB
