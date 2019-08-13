# Description
The purpose of this image is to allow injecting configuration via a GIT repository into an instance that does not natively supports this pattern.

# Supported FROM
  This scheme is not supported on `scratch` or `busybox`, it requires that envsubst can be installed.
Tested on Alpine, Centos and Ubuntu.