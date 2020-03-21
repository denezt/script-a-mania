### These are steps to have a program or script start on boot on a linux machine using Systemctl.

1. Run this command<br>
`sudo nano /etc/systemd/system/YOUR_SERVICE_NAME.service`

2. Paste in the command below. Press ctrl + x then y to save and exit<br>
Description=GIVE_YOUR_SERVICE_A_DESCRIPTION<br>
Wants=network.target<br>
After=syslog.target network-online.target<br>
[Service]<br/>
Type=simple<br/>
ExecStart=YOUR_COMMAND_HERE<br/>
Restart=on-failure<br/>
RestartSec=10<br/>
KillMode=process<br/>
[Install]<br/>
WantedBy=multi-user.target<br/>

3. Reload Services<br/>
`sudo systemctl daemon-reload`

4. Enable the service<br/>
`sudo systemctl enable YOUR_SERVICE_NAME`

5. Start the service<br/>
`sudo systemctl start YOUR_SERVICE_NAME`

6. Check the status of your service<br/>
`systemctl status YOUR_SERVICE_NAME`

7. Reboot your device and the program/script should be running. If it crashes it will attempt to restart.<br/>
