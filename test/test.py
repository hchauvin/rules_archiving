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

import tarfile
import unittest
import os

TEST_DATA_TARGET_BASE='test'

def TestData(name):
    return os.path.join(os.environ['TEST_SRCDIR'], 'hchauvin_rules_archiving',
                        TEST_DATA_TARGET_BASE, name)

def Tarball(name):
    path = TestData(name)
    return tarfile.open(path, mode='r')

class PkgTest(unittest.TestCase):

    def assertPaths(self, tar, paths):
        # TODO: do not use sort(), as builds must be reproducible.
        self.assertEqual(paths.sort(), tar.getnames().sort())

    def test_archive(self):
        with Tarball('archive.tar') as tar:
            self.assertPaths(tar, [
                'a.txt',
                'path/b.txt',
                '.',
                './dep',
                './dep/c.txt',
                './dep/foo',
                './dep/foo/d.txt',
                '.',
                './prefixed',
                './prefixed/by',
                './prefixed/by/dep',
                './prefixed/by/dep/c.txt',
                './prefixed/by/dep/foo',
                './prefixed/by/dep/foo/d.txt',
            ])

if __name__ == '__main__':
    unittest.main()