blink_record
============

A wrapper script to Team Fortress 2 (tf2) too ease recording using linux in the absence of prec.

What's new?
-----------
Version 0.1
* Rewrote the install script in ruby.
* Added graphical interface to installer.
* As valve removed the path in appmanifest it's no longer autodetected but prompted with file chooser.
* Added move demo files functionality. (Installer starts on tf2 default path)

Screenshots
-----------
Example of some gui dialogs.

![ScreenShot](http://i.imgur.com/JQ86kcx.png)
![ScreenShot](http://i.imgur.com/FQzEqyd.png)

What does it do?
----------------

The script allowes you to stop/start record demos in tf2 with a single key press. It also gives
the option where to save renamed demo files.

The resulting filename is:
`YYYYMMDD_HHMM_MAPNAME-NICK_DURATION.dem` (e.g. 20131021_044823_pl_badwater-Nisseblink_41m24s.dem)
It will sort nicely with prec demo files.

How do I install it?
----------------
* Make backup of your existing configs. You should always have a backup...
* If you are using Ubuntu/Debian/Mint etc. Open a terminal and run (copy paste this):

  gksudo apt-get install -y ruby wget && wget https://github.com/nisseblink/blink_record/archive/master.zip -O blink_record-master.zip && unzip -o blink_record-master.zip && cd blink_record-master && ./installer.rb

* Open blink_record that you should be able to find through your favorite application launcher (it will launch tf2).
* Open console and type `bind KEY blink_record` e.g. `bind f6 blink_record`.
* (If you have unbindall you need to edit them and add `bind KEY blink_record` at the appropriate location(s).)

How do I use it?
----------------
* Use the blink_recorder to launch tf2.
* Use your binded key to cycle start/stop recording.
* Next time you launch blink_record, demo files recorded with the script will be renamed.

FNAQ
===========

OMG WFT .EXE VAC BANNED!? etc
------------
No, just no.
This setup does not inject itself, it's not a plugin, it does not run in the background,
it does not do anything but:
[How does it work](https://github.com/nisseblink/blink_record#how-does-it-work)

Does it work with tf2lobby, tf2pickup etc?
------------------------------------------

It should. But you need to assign steam links to blink_record.
In firefox you do this in Edit/Preferences/Applications.
Content type: steam
Action: Use other, then /usr/local/bin/blink_record

Requirements
----------------
**During installation**
* gksudo (used for installing ruby and copy binary and application launcher)
* Team Fortress 2
* zenity (Steam uses this so should already be installed)

**Application runtime**
* Ruby
* Team Fortress 2
* zenity (Steam uses this so should already be installed)

How does it work
----------------
There is two components to this setup, tf2 script and a wrapper.

**Team Fortress 2 script**

This add a couple of aliases for a cycle of 20 recordings.
The installer also adds execution of the config in autoexec if it exists or adds this file.

**Wrapper**

* Locate demo files in tf directory.
* Parse headers of demo files.
* Rename the files and move them.
* Start Team Fortress 2.
* That is it.

Source code
===========
I encourage you to browse through the source code and look for yourself what is happening.
There are about 300 lines of code so it should not be a problem.

Feel free to contribute to the project by sending me changes/bugfixes or simply bugreports :)

The project is released under the GLPv3 licence.

Future possible features
========================

So there might be a way to achive a similar feature as prec's bookmark.
Technically this could be achieved by using a dekstop global keybinding that
calls a script that logs the time to a file and then handle it
when renaming the demo files. Let me know what you think about this.

It's also possible to group screenshots taken by steam with demo files.
For status and result screenshots. This will require the user to press the in-game screenshot button though.
