# you have to run this as root
# It only runs on Linux (namespaces and cgroups only exist on Linux)
# if you don't have it, cgcreate is in the libcgroup package

set -eux # let's be safe

# Download the container (it's in a github gist published by my github account)
# This is just the frapsoft/fish Fish Docker container flattened into a single tarball
# You can also easily make your own tarball to run instead of this one  with `docker export`
docker pull frapsoft/fish:latest
docker export frapsoft/fish:latest -o fish.tar
