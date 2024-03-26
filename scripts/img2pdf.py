#!/bin/env python3
import os
import sys
import subprocess

files_to_process = sorted(sys.argv[1:])

out_path = os.path.dirname(sys.argv[1])

# Determine output file name: common prefix of given files names
# Ex: 'page1.jpg', 'page2.jpg', 'page3.jpg' -> 'page.pdf'
out_filename = os.path.commonprefix([os.path.basename(i) for i in files_to_process]) + '.pdf'

# Convert
# subprocess.call("img2pdf",  + " ".join(files_to_process) + f" --output \"{out_path}/{out_filename}\"")
subprocess.run(["img2pdf", *files_to_process, "--output", f"{out_path}/{out_filename}"], capture_output=True, text=True)
