# Git Credentials 101


### Prerequisites
* Git Server
* Git client 2.37.2 or higher

## Activate Git Credentials
1. Creates the default gitconfig file is not exists.
2. Displays git config global attributes.
3. Will add the username and email if missing via prompting.

``` sh
# Execute the following script
$ ./setup.sh
```

#### Output:

<pre>
Found Git Credentials: /home/mmustermann/.git-credentials
Found config /home/mmustermann/.gitconfig. Do you want to view it?
[yes|no] yes

[user]
	email = mmustermann@email.com
	name = Max Mustermann
[http]
	sslCert = /home/mmustermann/.ssh/client.cert
	sslKey = /home/mmustermann/.ssh/client.key
[init]
	defaultBranch = main
[push]
	autoSetupRemote = true
[credential]
	helper = store
</pre>

#### Will Appear only if the [user] and [email] values are missing:

<pre>
Missing user.name parameter.
Would you like to add this parameter?
[yes|no] yes
Enter value for user.name:
Max Mustermann
Missing user.email parameter.
Would you like to add this parameter?
[yes|no] yes
Enter value for user.email:
mmustermann@email.com
</pre>

<pre>
View Global Settings:

user.email=mmustermann@email.com
user.name=Max Mustermann
http.sslcert=/home/mmustermann/.ssh/client.cert
http.sslkey=/home/mmustermann/.ssh/client.key
init.defaultbranch=main
push.autosetupremote=true
credential.helper=store
</pre>


## An example of the ~/.gitconfig configuration file

<pre>
user.email=max.mustermann@mail.de
user.name=Max Mustermann
http.sslcert=/home/mmustermann/.ssh/client.cert
http.sslkey=/home/mmustermann/.ssh/client.key
credential.helper=store
init.defaultbranch=main
push.autosetupremote=true
</pre>

