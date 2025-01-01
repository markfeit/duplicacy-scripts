# duplicacy-scripts

This is a set of scripts that can be used to manage running
[Duplicacy](https://duplicacy.com)([GitHub](https://github.com/gilbertchen/duplicacy))
on Unix systems.  They were developed and tested under Linux but
should work in any environment that complies with POSIX except Windows
(see note below).

## Notes

**Release 1.3:** The `duplicacy` binary that was manually installed in
  the top-level directory per the instructions from earlier versions
  is no longer used and may be removed.

These scripts download and use the Duplicacy binary from [Gilbert
Chen's release
page](https://github.com/gilbertchen/duplicacy/releases) on GitHub.
The license for Duplicacy imposes some restrictions on its use.
Please abide by them.

Limitations in the current implementation of Duplicacy and the fact
that Windows does not handle symbolic linking in a POSIX-like way
makes these scripts unsuitable for that environment.



## Prerequisites

Your system must have the following installed:

 * A POSIX-compliant environment
 * cURL
 * GNU Make
 * jq


## Installation

To install this package on your system:

Clone this repository:  `git clone https://github.com/markfeit/duplicacy-scripts.git`

`cd duplicacy-scripts`


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
`CONFIG_AUTO_UPDATE` is enabled:

 * Any changes in the original GitHub repository will be applied to
    `$DEST/etc/settings-update` rather than overwriting `settings`.

* The Duplicacy binary will be updated as new releases happen.  Any
  breaking changes in that will be breaking changes here as well.

At this point, backups and maintenance will be done automatically by
cron.


## Backups and Maintenance

Backups are run at 00:45 local time each morning.  If there is another
backup running (common when there is a long initial backup running),
the newer backup will be aborted.

Maintenance happens in this order:

 * Remove old log files per `CONFIG_LOG_LIFE` in the settings.

 * Remove old temporary files

 * Daily: Prune old snapshots according to the rules in `etc/prune`.
   If a pruning does not take place because maintenance is disabled,
   the cache is manually trimmed per `CONFIG_CACHE_LIFE` in the
   settings.

 * Weekly: Exhaustively prune all storages and snapshots to get rid of
   fossils and orphans.

 * Weekly: Do an integrity check of all storages and snapshots.

 * Daily: Update duplicacy-scripts if `CONFIG_AUTO_UPDATE` is enabled
   in the settings.


Logs of what happens during each backup and other matinenance
activities are stored in `$DEST/var/log`.  The latest logs or those
for a specific date can be retrieved and read with `$DEST/bin/logs`.


## Restoring Files

To restore files, execute `$DEST/bin/restore`.  Detailed help may be
obtained with the `--help` switch.
