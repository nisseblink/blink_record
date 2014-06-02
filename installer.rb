#!/usr/bin/env ruby
# encoding: utf-8
require 'fileutils'
require 'logger'
require 'find'

$version = 0.3
$blink_binary_path = '/usr/local/bin/blink_record'
$blink_desktop_shortcut="#{(`xdg-user-dir DESKTOP`).strip}/blink_record.desktop"
$blink_application_shortcut='/usr/share/applications/blink_record.desktop'
$blink_autostart_shortcut="#{File.expand_path("~/.config/autostart")}/blink_record.desktop"

$default_tf2_dir = File.expand_path("~/Steam/SteamApps/common/Team Fortress 2")

$logger = Logger.new(File.expand_path("~/.blink_record.log"), 4, 1024000)

#Quick hack for choosing graphical sudo if it exists
$sudo_binary = "sudo"
$sudo_binary = "gksudo" if system("which gksusdo > /dev/null 2>&1")
$sudo_binary = "kdesudo" if system("which kdesudo > /dev/null 2>&1")


class BlinkRC
  attr_accessor :settings,:path

  def initialize(path="~/.blink_recordrc")
    path = File.expand_path(path)
    @path = path
    @settings = Hash.new
    if(File.exists?(path))
      $logger.info "Reading from rc file."
      File.open(path) do |file|
        file.readlines.each do |line|
          l = line.split(":")
          @settings[l[0].strip] = l[1].strip
        end
      end
    end
  end

  def save
    File.open(@path, "w") do |file|
      @settings.each_pair do |key, value|
        file.puts(key + ":" + value)
      end
      $logger.info "Saved rc file"
    end
  end
end

def browse_for_tf2_dir(start_dir)
  start_dir = $default_tf2_dir unless start_dir

  dir = ""
  while true
    title = "Choose your tf2 dir (i.e. ..SteamApps/common/Team Fortress 2/)"
    zen_str = "zenity --title='#{title}' --file-selection --directory "\
      "--filename='#{start_dir}'"
    dir = `#{zen_str}`.strip
    #User chose Cancel
    if(dir == "")
      error_msg = "Can't install this without getting a tf2 directory."\
        "\nPlease rerun installer if you change your mind."
      system("zenity --text='#{error_msg}' --error")
      $logger.warn("User canceled tf2_dir dialog")
      abort("User canceled tf2_dir dialog")
    end
    if(dir =~ /SteamApps\/common\/Team Fortress 2$/)
      break
    else
      error_text = 'Please select your tf2 directory'\
        '(should end with SteamApps/common/Team Fortress 2)'
      system("zenity --text='#{error_text}' --info")
    end
  end
  dir
end

def browse_for_move_path(start_dir)
  start_dir = File.join($default_tf2_dir, "tf") unless start_dir

  dir = ""
  while true
    title = "Select path where to move demo files."
    zen_str = "zenity --title='#{title}' --file-selection --directory "\
      "--filename='#{start_dir}'"
    dir = `#{zen_str}`.strip
    #User chose Cancel
    if(dir == "")
      error_msg = "Taking this as you want to cancel this installation."
      system("zenity --text='#{error_msg}' --error")
      $logger.warn("User canceled move_path dialog")
      abort("User canceled move_path dialog")
    end
    if(File.writable?(dir))
      break
    else
      error_text = 'Directory was not writable by the user.'
      system("zenity --text='#{error_text}' --info")
    end
  end
  dir
end

def show_install_complete_dialog
  title = 'Installation complete!'
  info = 'To use blink_record, start tf2 and use your binded keys.'
  system("zenity --title='#{title}' --text='#{info}' --info")
end

#Retuns path if found and nil otherwise
def find_autoexec(search_path)
  Find.find(File.join(search_path, "tf", "custom")) do |path|
    if(!FileTest.directory?(path) && File.basename(path) == "autoexec.cfg")
      return path
    end
  end
  nil
end

#Adds/removes blink_record to autoexec and return
#true if autoexec has been found, false otherwise
def find_and_alter_autoexec(tf2_dir, remove)
  autoexec_found = false
  Find.find(File.join(tf2_dir, "tf", "custom")) do |path|
    if(!FileTest.directory?(path) && File.basename(path) == "autoexec.cfg")
      autoexec_found = true
      autoexec_raw_array = File.open(path){|file| file.readlines}
      autoexec_raw = autoexec_raw_array.join
      exec_uid = /^exec blink_record \/\/88b9a67a-815c-4e1a-b4b2-ffbac1fddff2$/
      #Remove if it exists and we are supposed to
      if(autoexec_raw =~ exec_uid && remove)
        $logger.info("autoexec contains automatic added blink_record:"\
                     " #{path}. Removing.")
        File.open(path, "w") do |file|
          autoexec_raw_array.each do |line|
            file.puts line unless line =~ exec_uid
          end
        end
        #Don't add if we are supposed to remove OR it already is defined.
      elsif(!(autoexec_raw =~ /^exec blink_record/ || remove))
        $logger.info("autoexec found but does not contain blink_record."\
                     " Adding it to: #{path}")
        File.open(path, "a") do |file|
          file.puts "exec blink_record //88b9a67a-815c-4e1a-b4b2-ffbac1fddff2"
        end
      end
      #We have found one autoexec. This should be enough for most cases.
      #TODO: Handle multiple results and promt the user which to use.
      return true
    end
  end
  false
end

def get_text_input(title, text, default_value)
    `zenity --title='#{title}' --text='#{text}' --entry --entry-text='#{default_value}'`.strip
end

def show_tf2_binds_dialogs(record_bind, bookmark_bind, grace)
  text = 'Cancel to skip this and make your own binds.'
  rk = get_text_input("Choose record key", text, record_bind)
  bmk = get_text_input("Choose bookmark key", text, bookmark_bind)

  text = 'Time(s) in the start/end that bookmarks will be handled as'\
    'status/scoreboard screenshots.\nCancel to disable this feature.'
  g = get_text_input("Choose a grace period", text, grace)

  [rk, bmk, g]
end

def install_blink_record
  blink_rc = BlinkRC.new
  settings = blink_rc.settings
  #Use default values if they exists in config file (updating/reinstallling)
  tf2_dir = browse_for_tf2_dir(settings["tf2_dir"])
  $logger.info("Using tf2_dir: #{tf2_dir}")
  move_path = browse_for_move_path(settings["move_path"])
  $logger.info("Using move_path: #{move_path}")
  #Save stuff to config file
  settings["tf2_dir"] = tf2_dir
  settings["move_path"] = move_path
  blink_rc.save

  cfg_dir = File.join(tf2_dir, "tf", "custom", "blink_record", "cfg")
  FileUtils.mkdir_p(cfg_dir)
  FileUtils.cp("src/blink_record.cfg", cfg_dir)
  altered = find_and_alter_autoexec(tf2_dir, false)
  #If autoexec didn't get altered, make a new one.
  unless(altered)
    $logger.info("Did not find autoexec file. Creating one: "\
                 "#{File.join(cfg_dir, "autoexec.cfg")}")
    File.open(File.join(cfg_dir, "autoexec.cfg"), "w") do |file|
      file.puts "exec blink_record //88b9a67a-815c-4e1a-b4b2-ffbac1fddff2"
    end
  end

  #Promt user for binds and grace period.
  binds = show_tf2_binds_dialogs(settings["record_bind"] || "f6",
                                 settings["bookmark_bind"] || "f11",
                                 settings["grace"] || "10")
  settings["record_bind"] = binds[0] unless binds[0].empty?
  settings["bookmark_bind"] = binds[1] unless binds[1].empty?
  settings["grace"] = binds[2] unless binds[2].empty?
  blink_rc.save
  File.open(File.join(cfg_dir, "blink_record.cfg"), "a") do |f|
    f.puts "bind #{settings["record_bind"]} blink_record" unless binds[0].empty?
    f.puts "bind #{settings["bookmark_bind"]} blink_bmark" unless binds[1].empty?
  end

  #Using gksudo so the user don't miss it as easily.
  #More coherent with all those flashy dialogs.
  system("#{$sudo_binary} -- cp src/blink_record #{$blink_binary_path}")
  system("#{$sudo_binary} -- cp src/blink_record.desktop "\
        "#{$blink_application_shortcut}")
  FileUtils.cp("src/blink_record.desktop", $blink_desktop_shortcut)
  if system("zenity --question --title='Autostart?' --text='Autostart with this"\
            " user?'")
    FileUtils.cp("src/blink_record.desktop", $blink_autostart_shortcut)
  end
  if system("zenity --question --title='Start blink_record?' --text='Do you"\
            " want to start blink_record?'")
    system("#{$blink_binary_path} &")
  end
  show_install_complete_dialog
end

def uninstall_blink_record
  system("#{$sudo_binary} -- rm #{$blink_binary_path}")
  system("#{$sudo_binary} -- rm #{$blink_application_shortcut}")
  FileUtils.rm($blink_desktop_shortcut) rescue nil
  FileUtils.rm($blink_autostart_shortcut) rescue nil

  config = BlinkRC.new
  unless(tf2_dir = config.settings["tf2_dir"])
    error_msg = "Could not find blink_recordrc file.\n"\
      "Will not remove tf2 cfg files."
    system("zenity --text='#{error_msg}' --error")
    $logger.warn("User canceled move_path dialog")
    abort("User canceled move_path dialog")
  end
  blink_tf2_config_path = File.join(tf2_dir, "tf", "custom", "blink_record")
  FileUtils.rm_r(blink_tf2_config_path)
  find_and_alter_autoexec(tf2_dir, true)
end

begin
  if ARGV.size > 0 && ARGV[0] == "--version"
    puts "blink_record installer version #{$version}"
    exit
  end
  #Promt user what to do
  column = 'What to do" TRUE "install" FALSE "uninstall'
  text = "What do you want to do?"
  zen_str = "zenity --list --radiolist --column=\"select\" "\
    "--column=\"#{column}\" --text \"#{text}\""
  action = `#{zen_str}`.strip
  if(action.empty?)
    exit
  elsif(action == "install")
    $logger.info("install selected")
    install_blink_record
    $logger.info("install complete")
  elsif(action == "uninstall")
    $logger.info("uinstall selected")
    uninstall_blink_record
    $logger.info("uninstall complete")
  else
    $logger.error("install/uninstall dialog did return something fishy: "\
                  "#{action}")
  end
rescue => e
  $logger.error(e)
  system("zenity --text='Unexpected error.\n#{e.message}' --error")
  abort("Unexpected error: #{e.message}")
end
