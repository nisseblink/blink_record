blink_record
============

An utility script and config to ease recording in Team Fortress 2 (tf2)
using linux in the absence of prec.

What's new?
-----------
Version 0.3
* Fixed bookmark functionality (steam moves screenshot files when there is
more than one screenshot with the same name).
* Added scoreboard/status screenshot functionality.
* Added key binding to installer.

Version 0.2
* Changed to running in background and using _inotify_. This will
  decouple blink_record from steam, the browser and tf2.
* Added bookmark functionality.

__To update, do a normal installation.__

If you are updating it note that it no longer supports steam links and
you should change back default application for steam links.

1. In Firefox you do this in Edit/Preferences/Applications.
2. Content type: steam
3. Action/Use other, then `/usr/games/steam`

Version 0.1
* Rewrote the install script in ruby.
* Added graphical interface to installer.
* As valve removed the path in appmanifest it's no longer autodetected
  but prompted with file chooser.
* Added move demo files functionality. (Installer starts on tf2 default
  path)

Screenshots
-----------
Example of some gui dialogs.

![ScreenShot](http://i.imgur.com/JQ86kcx.png)
![ScreenShot](http://i.imgur.com/FQzEqyd.png)

What does it do?
----------------

The script allows you to stop/start record demos in tf2 with a single
key press. It also gives the option where to save renamed demo files.

The resulting filename is: `YYYYMMDD_HHMM_MAPNAME-NICK_DURATION.dem`
(e.g. 20131021_044823_pl_badwater-Nisseblink_41m24s.dem) It will sort
nicely with prec demo files.

It also adds bookmark functionality and even a screenshot of the time of
the bookmark.

How do I install it?
----------------
* Make backup of your existing tf2 config. You should always have a
  backup...
* If you are using Ubuntu/Debian/Mint etc. Open a terminal and run (copy
  paste this):
```
gksudo -- apt-get install -y ruby ruby-inotify wget && \
wget https://github.com/nisseblink/blink_record/archive/master.zip -O blink_record-master.zip && \
unzip -o blink_record-master.zip && cd blink_record-master && ./installer.rb
```

How do I use it?
----------------
* Make sure that blink_record is running.
* Start tf2
* Use your record key to cycle start/stop recording.
* Use your bmark key to add a bookmark to a demo.
* Status/scoreboard screenshots are added if you take a bookmark within
  the grace period set during installation.

FNAQ
===========

OMG WFT .EXE VAC BANNED!? etc
------------
This setup does not inject itself and it's not a plugin.
However it _does_ run in the background. It's only functionality is
reading/moving files that steam/tf2 have already closed.

It does not do anything but:
[How does it work](https://github.com/nisseblink/blink_record#how-does-it-work)

Does it work with tf2lobby, tf2pickup etc?
------------------------------------------
Yes and it no longer requires you to start tf2 through it. If you have
changed the default launcher for steam links please change it back.

Requirements
----------------

* Ruby (and inotify gem)
* Team Fortress 2
* zenity (Steam uses this so should already be installed)

How does it work
----------------
There is two components to this setup, tf2 script and a daemon.

**Team Fortress 2 script**

This add a couple of aliases for a cycle of 20 recordings. The
installer also adds execution of the config in autoexec if it exists or
adds this file.

**Daemon**

* Listening for newly closed files in tf directory
* If demo file, parse header.
* Rename the files and move them.
* Checks for screenshots taken during the demo recording and adds
  bookmarks/status/scoreboard to the demo.
* That is it.

Source code
===========
I encourage you to browse through the source code and look for yourself
what is happening. There are about 400 lines of ruby code so it should not be
a problem.

Feel free to contribute to the project by sending me changes/bug fixes or
simply bug reports :)

The project is released under the GLPv3 licence.

What to work on next?
========================
Better UI. Zenity is not really that great for using in a installation
wizard. Perhaps use ruby-qt and have some optional systray,
notifications and settings.

Gem-ify it?
