#!/usr/bin/env ruby

# Ruby 2.3 script to stabilize a video, or all videos of a directory using ffmpeg/libvidstab
# Create a "stab" subdir and put stabilized files inside. Keep original files.


require 'pp'
require 'open3'
require 'fileutils'


ZENITY_WITH_OPTIONS = 'zenity --progress --title=Working... --text=Stabilisation... --auto-close'
FFMPEG_COMMANDS = [
  'ffmpeg -loglevel error -i "{input_file}" -vf vidstabdetect=result="{input_file}.trf" -f null -',
  'ffmpeg -loglevel error -i "{input_file}" -vf vidstabtransform=input="{input_file}.trf":smoothing=30 -acodec copy -vcodec h264 -preset slow -tune film -crf 23 "{output_file}"'
]

$log = ''  # Unused for now, but could be presented to user at the end of the process

# Execute extrnal command and return all output streams as string
def exec_command(command)
  log = ''
  puts "\n=> Executing \"#{command}\""
  log += "\n\n=> Executing \"#{command}\"\n"
  Open3.popen2e(command) { |stdin, stdout_and_stderr, wait_thr|
    stdout_and_stderr.each {|line|
      puts line
      log += line
    }
  }
  return log
end

def ffmpeg_pass(input_filename, pass_nb, out_dir)
  trf_file = "#{input_filename}.trf"
  File.delete(trf_file) if pass_nb == 1 and File.exist?(trf_file)
  output_file = File.join(out_dir, File.basename(input_filename))
  command = FFMPEG_COMMANDS[pass_nb-1].gsub('{input_file}', input_filename).gsub('{output_file}', output_file)
  $log += exec_command(command)
end

def percent(done, total)
  percent = (done / Float(total)) * 100
  puts "\n--- #{percent} %\n"
  return percent
end

### Main

if ARGV.length != 1
  puts "Syntaxe: #{$PROGRAM_NAME} [source_dir or source_file]"
  exit
end

source = ARGV[0]
if File.file?(source)
  source_dir = File.dirname(source)
  files_to_treat = [source]
else
  source_dir = source
  files_to_treat = Dir[File.join(source_dir, '*')].select{ |filename| File.file?(filename) and not filename.end_with?('.trf') }
end

# Clean dest dir
out_dir = File.join(File.join(source_dir, "stab"))
FileUtils.rm_r(out_dir) if Dir.exist?(out_dir)
Dir.mkdir(out_dir)

total_nb_files = files_to_treat.length
total_nb_actions = total_nb_files * 2

begin
  IO.popen(ZENITY_WITH_OPTIONS.split(' '), 'w') do |io|
    actions = 0
    files_to_treat.each do |filename|
      puts("=> " + filename)
      # First pass
      ffmpeg_pass(filename, 1, out_dir)
      actions += 1
      io.puts(percent(actions, total_nb_actions))  # send percent to zenity
      # Second pass
      ffmpeg_pass(filename, 2, out_dir)
      actions += 1
      io.puts(percent(actions, total_nb_actions))  # send percent to zenity
    end
  end
rescue Errno::EPIPE
  # Do not terminate when zenity closed
end

# Remove trf files
Dir[File.join(source_dir, '*.trf')].each{ |filename| File.delete(filename) }
puts "\nEND"

# End
%x( zenity --info --text="Fini !" )
