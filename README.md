# duplicacy-scripts

This is a set of scripts that can be used to manage running
[Duplicacy](https://duplicacy.com)([GitHub](https://github.com/gilbertchen/duplicacy)) on Unix systems.
They were developed and tested under Linux but should work in any
environment that complies with POSIX.

**NOTE:** Limitations in the current implementation of Duplicacy and
the fact that Windows does not handle symbolic linking in a POSIX-like
way makes these scripts unsuitable for that environment.


## Installation

To install this package on your system:

Clone this repository:  `git clone https://github.com/markfeit/duplicacy-scripts.git`

`cd duplicacy-scripts`

Download the Duplicacy binary from [Gilbert Chen's release
page](https://github.com/gilbertchen/duplicacy/releases) or [build one
of your own](https://github.com/markfeit/duplicacy-dev) and and place
the file in `duplicacy-scripts/duplicacy` .  Note that the license for
Duplicacy imposes some restrictions on its use.  Please abide by them.

Select a location where duplicacy-scripts, the Duplicacy
configuration, its cache and log files will be kept.  This location
will be referred to as `$DEST`.  The default is `/opt/duplicacy`.

Select the location which will form the root of the volume(s) to be
backed up.  This will be referred to as `$ROOT`.  The default is `/`,
which is suitable for most systems.  (Specific parts of the filesystem
may be included or excluded using Duplicacy's filter mechanism.)

Become `root` and execute:

 * `make install` to install using the defaults
 * `make DEST=$DEST ROOT=$ROOT install` to install using other directories.

Installation may be done as any other user, but be aware that this
will limit the set of files backed up to those the user can read.  In
addition to installing these scripts, a `.duplicacy` file will be
placed in `$ROOT`.

Set up Duplicacy by placing a `preferences` and optional `filter` file
in `$DEST/prefs` Samples are provided in the `prefs` directory of the
sources.  These files are not installed by default.

Set up the scripts by editing `$DEST/etc/settings`.  Note that if
`CONFIG_AUTO_UPDATE` is enabled, any changes in the original GitHub
repository will be applied to `$DEST/etc/settings-update` rather than
overwriting `settings`.

At this point, backups and maintenance will be done automatically by
cron.


## Backups

Backups are run at 00:45 local time each morning.  If there is another
backup running (common when there is a long initial backup running),
the newer backup will be aborted.

Logs of what happens during each backup and other matinenance
activities are stored in `$DEST/var/log`.  The latest logs or those
for a specific date can be retrieved and read with `$DEST/bin/logs`.


## Restoring Files

To restore files, execute `$DEST/bin/restore`.  Detailed help may be
obtained with the `--help` switch.


## Maintenance

Daily (03:00):

 * Prune old snapshots according to the rules in `etc/prune`.
 * Remove old log files per `CONFIG_LOG_LIFE` in settings.
 * Remove old cache files per `CONFIG_CACHE_LIFE` in settings.
 * Pull and update the software (if enabled in `$DEST/etc/settings`).

Weekly (Sunday at 03:15):

 * Fossilize and remove chunks that are no longer referenced.
 
 * Check integrity.  This verifies that all chunks that should be
   present and attempts to resurrect missing chunks from fossils if
   possible. There is no attempt to download and verify the contents
   of the chunks.  (Not implemented yet.)

Monthly (First Sunday at 03:30):

 * Nothing yet.
