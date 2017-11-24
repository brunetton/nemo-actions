#!/usr/bin/env python
# -*- coding: utf-8 -*-

# extract sound from a video file, giving it correct extension

import os
import sys
import subprocess

assert len(sys.argv) > 1

def execute(command):
    process_output = subprocess.check_output(command, shell=True)
    try:
        cmnd_output = subprocess.check_output(command, stderr=subprocess.STDOUT, shell=True);
    except subprocess.CalledProcessError as exc:             # subprocess returned non 0 output code
        print("Status : FAIL", exc.returncode, exc.output)
    else:
        print("Output: \n{}\n".format(cmnd_output))
    return cmnd_output

def show_error(text, type='info'):
    """Show a GUI message to user, using Zenity
    type can be: 'error', 'info', or other supported by zenity"""
    print(text)
    execute('zenity --error --text="{}"'.format(text))

def remove_path_and_extension(filepath):
    return os.path.splitext(os.path.basename(filepath))[0]


in_filepaths = [argv for argv in sys.argv[1:]]
out_path = os.path.dirname(in_filepaths[0])
out_filename = " + ".join(remove_path_and_extension(filepath) for filepath in in_filepaths) + '.wav'

sox_command = "sox {} {}".format(
    " ".join(['"{}"'.format(filepath) for filepath in in_filepaths]),
    '"{}"'.format(os.path.join(out_path, out_filename))
)
print("sox_command: {}".format(sox_command))
execute(sox_command)
