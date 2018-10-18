#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

for dirpath, dirnames, filenames in os.walk(sys.argv[1], topdown=False, onerror=None, followlinks=False):
    print("dirpath: {!r}, dirnames: {!r}, filenames: {!r}".format(dirpath, dirnames, filenames))
    # We don't use dirnames given by os.walk() as it's not updated with deleted ones
    actual_dirnames = [dirname for dirname in os.listdir(dirpath) if os.path.isdir(os.path.join(dirpath, dirname))]  # List source_dir subdirs
    if len(filenames) + len(actual_dirnames) == 0:
        os.rmdir(dirpath)
