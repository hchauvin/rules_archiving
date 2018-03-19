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

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "dep_tar",
    srcs = glob(["dep/**/*"]),
    strip_prefix = ".",
)

load("@hchauvin_rules_archiving//:defs.bzl", "tar_archive")

tar_archive(
    name = "archive",
    deps_append = [":dep_tar"],
    deps_prefixed = {
        ":dep_tar": "prefixed/by",
    },
    srcs_rename = {
        "strip/a.txt": "a.txt",
        "strip/path/b.txt": "path/b.txt",
    },
)

py_test(
    name = "test",
    size = "small",
    srcs = ["test.py"],
    data = ["archive.tar"],
)
