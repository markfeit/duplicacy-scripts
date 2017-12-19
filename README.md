# duplicacy-scripts

**NOTE:  These scripts are a work in progress.  Use them at your own risk.**

This is a set of scripts that can be used to manage running
[Duplicacy](https://duplicacy.com)
([GitHub](https://github.com/gilbertchen/duplicacy)) on Unix systems.
They were developed and tested under Linux but should work in any
environment that complies with POSIX.

**NOTE:** Limitations in the current implementation of Duplicacy
prevent these scripts from working properly on Windows systems where
there are multiple drives to be backed up.


## Installation

To install this package on your system:

Clone this repository:  `git clone https://github.com/markfeit/duplicacy-scripts.git`

`cd duplicacy-scripts`

Download the Duplicacy binary from [Gilbert Chen's release
page](https://github.com/gilbertchen/duplicacy/releases) and place the
file in `duplicacy-scripts`.  Note that the license for Duplicacy
imposes some restrictions on its use.  Please abide by them.

Select a location where duplicacy-scripts, the Duplicacy
configuration, its cache and log files will be kept.  This location
will be referred to as `$DEST`.  The default is `/system/duplicacy`.

Select the location which will form the root of the volume(s) to be
backed up.  This will be referred to as `$ROOT`.  The default is `/`,
which is suitable for most systems.  (Specific parts of the filesystem
may be included or excluded using Duplicacy's filter mechanism.)

Become `root` and execute `make DEST=$DEST ROOT=$ROOT install`.  You
may do this as any other user, but be aware that this will limit the
set of files backed up to those the user can read.  In addition to
installing these scripts, a `.duplicacy` file will be placed in
`$ROOT`.

Set up Duplicacy by placing a `preferences` and optional `filter` file
in `$DEST/prefs` Samples are provided in the `prefs` directory of the
sources.  These files are not installed by default.

At this point, backups and maintenance will be done automatically by
cron.


## Backups

Backups are run at 00:45 local time each morning.  If there is another
backup running (common when there is a long initial backup running),
the newer backup will be aborted.

Logs of what happens during each backup and other matinenance
activities are stored in `$DEST/var/log`.


## Maintenance

Daily (03:00):

 * Prune old snapshots according to the rules in `etc/prune`.
 * Remove log files older than 30 days.

Weekly (Sunday at 03:15):

 * Check integrity.  This verifies that all chunks that should be
   present and attempts to resurrect missing chunks from fossils if
   possible. There is no attempt to download and verify the contents
   of the chunks.  (Not implemented yet.)

Monthly (First Sunday at 03:30):

 * Prune using the exhaustive mode to find and eliminate unused
   chunks.  (Not implemented yet.)

