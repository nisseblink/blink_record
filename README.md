blink_record
============

A wrapper script to Team Fortress 2 (tf2) too ease recording using linux in the absence of prec.

FNAQ
===========

OMG WFT .EXE VAC BANNED!? etc
------------
No, this setup does not inject itself in any way or do anything but:
* Locate demo files in tf directory.
* Parse headers of demo files.
* Rename the files.
* Start Team Fortress 2.
* And we are done.

How do I install it?
----------------
* Make backup of your existing configs. You should always have a backup...
* Download the archive, extract and run the `install.sh` (In a terminal preferably)
* Open blink_record that you should be able to find through your favorite application launcher (it will launch tf2).
* Open console and type `bind KEY blink_record` e.g. `bind f6 blink_record`.
* If you have unbindall you need to edit them and add `bind KEY blink_record` at the appropriate location(s).

How do I use it?
================
* Use the blink_recorder to launch tf2.
* Use your binded key to cycle start/stop recording.
* Next time you launch tf2 all your demo files will be renamed.

Requirements
============
The automatic script is built for Ubuntu/Debian/Linux Mint etc and it needs apt-get to install the *ruby* environment.
If you have some other distribution, install *ruby* before and you should be fine.

Automatic installation
----------------------
* gksudo (used for installing ruby and copy binary and application launcher)
* Team Fortress 2

Application
---------------------
* Ruby
* Team Fortress 2

How does it work
================
There is two components to this setup, tf2 script and a wrapper.

Team Fortress 2 script
----------------------

This add a couple of aliases for a cycle of 20 recordings.
The installer also adds execution of the config in autoexec if it exists or adds this file.

Wrapper
-------
As stated in **OMG WFT .EXE VAC BANNED!? etc**

Source code
===========
I encourage you to browse through the source code and look for yourself what is happening.
There are < 200 lines of code so it should not be a problem.

Feel free to contribute to the project by sending me changes/bugfixes or simply bugreports :)

Future possible features
========================

So there might be a way to achive a similar feature as prec's bookmark.
Technically this could be achieved by using a dekstop global keybinding that
calls a script that logs the time to a file and then handle it
when renaming the demo files. Let me know what you think about this.
