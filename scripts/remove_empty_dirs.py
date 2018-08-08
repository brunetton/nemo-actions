#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

for dirpath, dirnames, filenames in os.walk(sys.argv[1], topdown=True, onerror=None, followlinks=False):
    if len(filenames) + len(dirnames) == 0:
        os.rmdir(dirpath)
