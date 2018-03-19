#!/usr/bin/env python

# Copyright 2017 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


"""
Build a .tar file from building instructions.
"""

import json
import sys
import tarfile
import tempfile
import os

def add_srcs(srcs, root, archive):
    """Add srcs (a list of files) to the archive."""
    for src in sorted(srcs, key=lambda k: k["to_path"]):
        archive.add(os.path.join(root, src["from_path"]), arcname=src["to_path"], recursive=False)

def add_deps(deps, root, archive):
    """Add dependencies (other .tar files) to the archive."""
    for dep in deps:
        tmp = tempfile.mkdtemp()
        tar = os.path.join(root, dep["tar"])
        if "prefix" in dep:
            extraction_path = os.path.join(tmp, dep["prefix"])
        else:
            extraction_path = tmp
        with tarfile.open(tar, "r:*") as src_archive:
            src_archive.extractall(path=extraction_path)
        archive.add(tmp, arcname=".", recursive=True)

def main():
    """
    Usage: tar_archive <roodir> <instructions.json> <archive.tar>

    <instructions.json> - a JSON file with building instructions.
    <archive.tar> - the resulting tarball.
    <rootdir> - what the files in instructions.json are relative from.
    """
    if len(sys.argv) != 4:
        print "Wrong command-line arguments!"
        sys.exit(1)
    with open(sys.argv[1]) as config_file:
        config = json.load(config_file)
    if sys.argv[2].endswith(".tar"):
        mode = "w:"  # uncompressed writing
    elif sys.argv[2].endswith(".tar.gz"):
        mode = "w:gz"
    elif sys.argv[2].endswith(".tar.bz2"):
        mode = "w:bz2"
    else:
        print "wrong output extension: %s" % sys.argv[2]
        sys.exit(1)
    # "dereference=True" ensures that symlinks are followed
    with tarfile.open(sys.argv[2], mode, dereference=True) as archive:
        add_srcs(config["srcs"], sys.argv[3], archive)
        add_deps(config["concatenate"], sys.argv[3], archive)

if __name__ == "__main__":
    main()
