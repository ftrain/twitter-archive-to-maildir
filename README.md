# Twitter archive to maildir

This is hacky stuff glued together from little experiments.

First, we import the tweet JSON to SQLite then turn that into a nice table.

To do that you gotta read through and run `./archive-to-maildir.sh`.

Why would you do it that way instead of just parsing right in python (see below)? Because you like the datasette tool that Simon Willison built and like having things in a SQLite table for further analysis and processing, even though you're not doing a lot of that processing right now. But eventually you might try to do some light rethreading, attaching images, adding some stats to tweets, etc, etc.

Turning SQL rows into a maildir is pretty simple using Python tools.

To do that here you gotta read through, modify, and run `./sqlite-to-maildir.py` and change variables.

A better person would add a `requirements.txt` and other niceties. But if you're down this rabbit hole already then what's another rabbit hole? TQDM isn't standard but I think everything else is.
