# `rules_archiving`

[![Build status](https://badge.buildkite.com/07667f996fda32883ec1e89be26c0ca5198ee0802c727d6828.svg)](https://buildkite.com/hchauvin/rules-archiving)

`rules_archiving` is a Bazel rule for building tarballs, with more flexibility than [`pkg_tar`](https://docs.bazel.build/versions/master/be/pkg.html#pkg_tar)

## Example

In your `WORKSPACE`:
```python
git_repository(
    name = "hchauvin_rules_archiving",
    remote = "https://github.com/hchauvin/rules_archiving.git",
    commit = "{HEAD}",
)
```

Then in a `BUILD` file:
```python
load("@hchauvin_rules_archiving//:defs.bzl", "tar_archive")

tar_archive(
    name = "archive",
    srcs_rename = {
        "//:from.txt": "to.txt",
    },
    # ...
)
```

## `tar_archive`

```python
tar_archive(srcs_rename, srcs, extension, deps_append, deps_prefixed)
```

Rule to produce a tarball from a set of files and tarballs.  It offers some
flexibility concerning how the files are laid out.  Among other things, it
allows the renaming of files, which might be in some cases more suitable than
symlinking, and can be used to avoid using multiple layers of [`pkg_tar`](https://docs.bazel.build/versions/master/be/pkg.html#pkg_tar) to
get to the desired layout.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>srcs_rename</code></td>
      <td>
        <p><code>label_keyed_string_dict; optional</code></p>
        <p>Dictionary of single files to strings.
        They are added to the tarball under the path given by the strings.  The labels
        can be outside the package invoking the rule.</p>
      </td>
    </tr>
    <tr>
      <td><code>srcs</code></td>
      <td>
        <p><code>list of files; optional</code></p>
        <p>The files must be within the package invoking the rule, and the paths in
        the tarball are relative to the package.</p>
      </td>
    </tr>
    <tr>
      <td><code>extension</code></td>
      <td>
        <p><code>String; default ".tar"</code></p>
        <p>Extension of the resulting tarball.  Can also be <code>".tar.gz"</code> or <code>".tar.bz2"</code>, in which case
        the tarball is compressed accordingly.</p>
      </td>
    </tr>
    <tr>
      <td><code>deps_append</code></td>
      <td>
        <p><code>List of tarballs; optional</code></p>
        <p>Tarballs (<code>"*.tar"</code>, <code>"*.tar.gz"</code>, ...) to append to the output of this rule,
        with no modification.</p>
      </td>
    </tr>
    <tr>
      <td><code>deps_prefixed</code></td>
      <td>
        <p><code>Dictionary of tarballs to strings; optional</code></p>
        <p>Tarballs (<code>"*.tar"</code>, <code>"*.tar.gz"</code>, ...) to append to the output of this rule after
        each of their files is prefixed by the corresponding string in the dictionary.</p>
      </td>
    </tr>
  </tbody>
</table>
