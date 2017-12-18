# duplicacy-scripts

**NOTE:  These scripts are a work in progress.  Use them at your own risk.**

This is a set of scripts that can be used to manage running Duplicacy
on Unix systems.  They were developed and tested under Linux but
should work in any environment that complies with POSIX.



## Installation

Download the Duplicacy binary from [Gilbert Chen's release page](https://github.com/gilbertchen/duplicacy/releases).  Note that the license for Duplicacy imposes some restrictions on its use.  Please abide by them.

Edit the `Makefile` and adjust the configuration at the top as you want it.

If you're backing up a full system, do a `make install` as `root`.  Otherwise, do it as a user that has enough access to do the backups you want.

Set up Duplicacy by placing a `preferences` file in `$DEST/prefs`

At this point, backups and maintenance will be done automatically by cron.  Logs can be found in `$DEST/var/log`.
