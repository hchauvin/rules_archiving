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

load(
    ":path.bzl",
    "get_package_dirname",
    "get_package_relative",
)

def _impl(ctx):
  dirname = get_package_dirname(ctx)

  # Marshal archiving instructions into a JSON file
  srcs = []
  for src in ctx.files.srcs:
    srcs.append(struct(
        from_path = src.path,
        to_path = "./" + get_package_relative(src, dirname)))
  for src in ctx.attr.srcs_rename.keys():
    src_files = src.files.to_list()
    if len(src_files) != 1:
      fail("Expected one file for key of srcs; instead got: %s" % src_files)
    srcs.append(struct(
        from_path = src_files[0].path,
        to_path = ctx.attr.srcs_rename[src]))

  concatenate = []
  for dep in ctx.files.deps_append:
    concatenate.append(struct(tar = dep.path))
  for dep in ctx.attr.deps_prefixed.keys():
    dep_files = dep.files.to_list()
    if len(dep_files) != 1:
      fail("Expected one file for key of deps_prefixed; instead got: %s" %
           dep_files)
    concatenate.append(struct(
        tar = dep_files[0].path,
        prefix = ctx.attr.deps_prefixed[dep]
    ))

  instructions = ctx.new_file("%s-archiving_instructions.json" % ctx.attr.name)
  ctx.file_action(
      output = instructions,
      content = struct(
          srcs = srcs,
          concatenate = concatenate).to_json())

  # Apply archiving instructions using `tar_archive`
  ctx.action(
      inputs = [instructions] + [
          src.files.to_list()[0] for src in ctx.attr.srcs_rename.keys()
      ] + ctx.files.srcs + ctx.files.deps_append +
      [dep.files.to_list()[0] for dep in ctx.attr.deps_prefixed.keys()],
      outputs = [ctx.outputs.tar],
      executable = ctx.executable._tar_archive,
      arguments = [
          instructions.path,
          ctx.outputs.tar.path,
          ".",
      ],)

tar_archive = rule(
    attrs = {
        "srcs_rename": attr.label_keyed_string_dict(allow_files = True),
        "srcs": attr.label_list(allow_files = True),
        "extension": attr.string(default = "tar"),
        "deps_append": attr.label_list(allow_files = FileType([
            ".tar",
            ".tar.gz",
        ])),
        "deps_prefixed": attr.label_keyed_string_dict(allow_files = FileType(
            [
                ".tar",
                ".tar.gz",
                ".tar.bz2",
            ],
        )),
        "_tar_archive": attr.label(
            executable = True,
            default = Label("//tools:tar_archive"),
            cfg = "host",
        ),
    },
    outputs = {
        "tar": "%{name}.%{extension}",
    },
    implementation = _impl,
)
