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

def get_dirname(path):
  """
  Get the directory name for `path`.
  """
  i = path.rfind("/")
  if i == -1:
    fail("get_dirname called but no parent path")
  return path[0:i]

def get_package_dirname(ctx):
  """
  Get the directory of the package under which a rule is executed.

  Args:
    ctx: The context of the rule.

  Returns:
    string: The directory.
  """
  return get_dirname(ctx.build_file_path)

def get_package_relative(file, package_dir):
  """
  Get path of file relative to package directory.

  If the file is not in the package directory, an error is raised.

  Args:
    file (File): The file.
    package_dir (string): The package directory, for instance gotten from `get_package_dirname`.

  Returns:
    string: Path relative to package directory.
  """
  short_path = file.short_path
  if short_path.startswith('../') and package_dir.startswith('external/'):
    short_path = 'external' + short_path[2:]
  if not short_path.startswith(package_dir):
    fail("source file '%s' is not within package '%s' or any subpackage" %
         (short_path, package_dir))
  return short_path[len(package_dir) + 1:]
