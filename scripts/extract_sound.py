#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import subprocess
import re


assert len(sys.argv) == 2

def execute(command):
    process_output = subprocess.check_output(command, shell=True)
    try:
        cmnd_output = subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True);
    except subprocess.CalledProcessError as exc:             # subprocess returned non 0 output code
        print("Status : FAIL", exc.returncode, exc.output)
    else:
        print("Output: \n{}\n".format(cmnd_output))
    return cmnd_output

in_complete_filename = sys.argv[1]
path = os.path.dirname(in_complete_filename)
in_filename_without_ext = os.path.splitext(os.path.basename(in_complete_filename))[0]

assert os.path.isfile(in_complete_filename)

# get audio stream type
ffprobe_infos = execute('ffprobe "{}"'.format(in_complete_filename))
match = re.search('Stream #.+: Audio: ([^ ]+)', ffprobe_infos)
if match:
    audio_format = match.group(1)
else:
    raise Exception("No audio found in file")
print "-> audio_format: {}".format(audio_format)

# WAV formats special case
if re.search('pcm_.*', audio_format):
    audio_format = "wav"

# Do the convertion
command = 'ffmpeg -i "{in_file}" -c:a copy "{out_file}" -y'.format(
    in_file = in_complete_filename,
    out_file = os.path.join(path, in_filename_without_ext + '.' + audio_format)
)
execute(command)
