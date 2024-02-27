## Configurations and Tools for setup of GPU for Data Science experiments

### Requirements:
* Linux OS
* User must have superuser access


### Quick Instruction Guide
```
# Execute the following command
$ ./setup.sh
$ ./setup.sh
```
### OUTPUT: 
<pre>
Info: Missing or unable to find local configuration /etc/X11/xorg.conf
Local Source etc/X11/xorg.conf:
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
EndSection
Adding Local Source entry into: /etc/X11/xorg.conf
Are you sure? [y|n]: y
Section "Device"
    Identifier "Intel Graphics"
    Driver "intel"
EndSection
Successfully, updated the XORG configuration!!
</pre>
