#!/usr/bin/env ruby

# Ruby 2.3 script to stabilize a video, or all videos of a directory using ffmpeg/libvidstab
# Create a "stab" subdir and put stabilized files inside. Keep original files.


require 'pp'
require 'open3'
require 'fileutils'


LANG = :en  # :en or :fr


TEXTS = {
  stabilization: {
    en: 'Stabilization ...',
    fr: 'Stabilisation ...',
  },
  smooth_factor: {
    en: 'Select smoothing factor\n(number of frames before <b>and after</b> where to look to detect movement)',
    fr: "Sélectionnez le smoothing factor\n(nombre d'images avant <b>et après</b> l'image actuelle\noù détecter du mouvement)",
  },
  finished: {
    en: 'Finished !',
    fr: 'Fini !',
  },
}


ZENITY_WITH_OPTIONS = "zenity --progress --title=Working... --text=#{TEXTS[:stabilization][LANG]} --auto-close"
DEFAULT_SMOOTHING_FACTOR = 6  # Number of frames to look befre and after current frame to detect movement.
FFMPEG_COMMANDS = [
  'ffmpeg -i "{input_file}" -vf vidstabdetect=result="{input_file}.trf" -f null -',
  'ffmpeg -i "{input_file}" -vf vidstabtransform=input="{input_file}.trf":smoothing={smoothing_factor} -acodec copy -vcodec h264 -preset slow -tune film -crf 23 "{output_file}"'
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

def ffmpeg_pass(input_filename, pass_nb, smoothing_factor, out_dir)
  trf_file = "#{input_filename}.trf"
  File.delete(trf_file) if pass_nb == 1 and File.exist?(trf_file)
  output_file = File.join(out_dir, File.basename(input_filename))
  command = FFMPEG_COMMANDS[pass_nb-1].gsub('{input_file}', input_filename).gsub('{output_file}', output_file).gsub('{smoothing_factor}', smoothing_factor)
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

# Ask user for smoothing factor
# See https://github.com/georgmartius/vid.stab
smoothing_factor = `zenity --scale --text="#{TEXTS[:smooth_factor][LANG]}" --value=#{DEFAULT_SMOOTHING_FACTOR} --min-value=2 --max-value=30 --step 4`
if not $?.success?
  puts "Cancelled by user"
  exit
end

total_nb_files = files_to_treat.length
total_nb_actions = total_nb_files * 2

begin
  IO.popen(ZENITY_WITH_OPTIONS.split(' '), 'w') do |io|
    actions = 0
    files_to_treat.each do |filename|
      puts("=> " + filename)
      # First pass
      ffmpeg_pass(filename, 1, smoothing_factor, out_dir)
      actions += 1
      io.puts(percent(actions, total_nb_actions))  # send percent to zenity
      # Second pass
      ffmpeg_pass(filename, 2, smoothing_factor, out_dir)
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
%x( zenity --info --text="#{TEXTS[:finished][LANG]}" )
