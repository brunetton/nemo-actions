#!/usr/bin/env ruby

# Ruby 2.3 script to execute the same command to multiple files, and display a process dialog.

require 'pp'
require 'open3'
require 'docopt'

ZENITY_WITH_OPTIONS = 'zenity --progress --title=Working... --auto-close'.freeze
$log = '' # Unused for now, but could be presented to user at the end of the process

doc = <<DOCOPT
Apply given command to multiple files and display a process dialog, using Zenity.
In command, "{}" will be replaced by each given filename.
When used in a nemo action, should be used with EscapeSpaces=true option in .nemo_action file.

Usage:
  #{__FILE__} <command_line> <filenames>...

Example:
  #{__FILE__} "ls -al {}" [filenames]

DOCOPT

# Execute external command and return all output streams as string.
# Raise if exit code is not OK
def exec_command(command)
  log = ''
  puts "\n=> Executing \"#{command}\""
  log += "\n\n=> Executing \"#{command}\"\n"
  Open3.popen2e({"SHELL" => "bash"}, command) do |_stdin, stdout_and_stderr, wait_thr|
    stdout_and_stderr.each do |line|
      puts line
      log += line
    end
    exit_status = wait_thr.value
    unless exit_status.success?
      # throw log
      raise log
    end
  end
  return log
end

def percent(done, total)
  percent = (done / Float(total)) * 100
  puts "\n--- #{percent} %\n"
  return percent
end

### Main

begin
  args = Docopt.docopt(doc)
rescue Docopt::Exit => e
  puts e.message
  exit
end

files_to_treat = args['<filenames>']

begin
  IO.popen(ZENITY_WITH_OPTIONS.split(' '), 'w') do |io|
    done = 0 # number of treated files
    files_to_treat.each do |filepath|
      puts('=> file: ' + filepath)
      file_command_line = args['<command_line>'].gsub('{}', filepath)
      exec_command(file_command_line)
      done += 1
      # send percent to zenity
      io.puts(percent(done, files_to_treat.length))
    end
  end
rescue => e
  puts("Error received: #{e}")
  system("zenity --width 500 --error --no-wrap --text \"Subprocess error:\n\n#{e.to_s.gsub('"', '\"')}\"")
  abort
end

puts "\nEND"

# End
`zenity --info --text="End"`
