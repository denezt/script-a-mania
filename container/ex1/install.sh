#!/bin/sh

[ "$( sudo apt list cgroup-tools 2> /dev/null | grep -o 'installiert' )" ] || sudo apt-get install cgroup-tools --yes
echo "Testing memory cgroup..."
sudo cgcreate -g memory:/mycontainer
echo "Running a memory-intensive process inside the cgroup..."
sudo cgexec -g memory:mycontainer dd if=/dev/zero of=/dev/null bs=1M count=200
echo "Memory-intensive process completed."
echo "If you see 'Killed' message above, the memory limit is enforced."
echo "Cleaning up..."
sudo cgdelete -g memory:/mycontainer
echo "Memory cgroup test completed."

