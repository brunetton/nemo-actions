#!/usr/bin/env ruby

# Ruby 2.3 script to execute the same command to multiple files, and display a process dialog.

require 'pp'
require 'open3'
require 'docopt'
require 'uri'

ZENITY_WITH_OPTIONS = 'zenity --progress --title=Working... --auto-close'.freeze
$log = '' # Unused for now, but could be presented to user at the end of the process

doc = <<DOCOPT
Apply given command to multiple files and display a process dialog, using Zenity.
In command, "{}" will be replaced by each given filename.

Usage:
  #{__FILE__} <command_line> <filenames>...

Example:
  #{__FILE__} "ls -al {}" [filenames]

DOCOPT

# Execute external command and return all output streams as string
def exec_command(command)
  log = ''
  puts "\n=> Executing \"#{command}\""
  log += "\n\n=> Executing \"#{command}\"\n"
  Open3.popen2e(command) do |_stdin, stdout_and_stderr, _wait_thr|
    stdout_and_stderr.each do |line|
      puts line
      log += line
    end
  end
  log
end

def percent(done, total)
  percent = (done / Float(total)) * 100
  puts "\n--- #{percent} %\n"
  percent
end

### Main

begin
  args = Docopt.docopt(doc)
rescue Docopt::Exit => e
  puts e.message
  exit
end

pp args
# Convert from "file:///tmp/tests%20wavs/1.wav" to "/tmp/tests wavs/1.wav"
files_to_treat = args['<filenames>'].map { |filename| URI.decode(URI.split(filename)[5]) }

begin
  IO.popen(ZENITY_WITH_OPTIONS.split(' '), 'w') do |io|
    done = 0 # number of treated files
    files_to_treat.each do |filepath|
      puts('=> ' + filepath)
      file_command_line = args['<command_line>'].gsub('{}', filepath)
      exec_command(file_command_line)
      done += 1
      # send percent to zenity
      io.puts(percent(done, files_to_treat.length))
    end
  end
end

puts "\nEND"

# End
`zenity --info --text="End"`
