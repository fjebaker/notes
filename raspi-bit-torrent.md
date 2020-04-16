# Setting up a Raspberry-Pi for secure bit torrenting.

The method for configuring the raspi as a torrenting node over vpn is based off of a 'trial and error' approach. It necessitates the use of `openvpn`, requiring itself valid `.ovpn` configuration files, which may require a premium service (successfully tested with NordVPN).

## Table of Contents
1. [Configuring OpenVPN](#configuring-openvpn)
2. [Configuring Transmission](#configuring-transmission)
3. [`elinks` for browsing torrent databases](#elink-config)
4. [Allowing SSH behind OpenVPN](#ssh-config)
5. [Useful scripts](#useful-scripts)

#### Installing pre-requisites
All of the prerequisites are installed with
```bash
sudo apt-get update
sudo apt-get install openvpn transmission-daemon transmission-common transmission-cli
# for the URI forwarding terminal browser, also need
sudo apt-get install elinks
```

### Configuring OpenVPN <a name="configuring-openvpn"></a>
We configure `openvpn` first, by editing/creating `/etc/openvpn/client.conf`, from some template `.ovpn` file provided by the VPN server. The starup routine of OpenVPN will configure the VPN according to this file, which often means a little editing is required, namely including `auth-user-pass` as
```
# ...

auth-user-pass .secrets

<ca>
-----BEGIN CERTIFICATE-----
# ...
```
and thus, create a `.secrets` file in `/etc/openvpn/`, storing the login details for the VPN server. This should be formatted
```
[username]
[password]
```
NB: the line break is essential. With this, OpenVPN will automatically login and start routing all (except LAN) traffic through the VPN on startup.

Next, we need to enable the `AUTOSTART="all"` flag in 
```
/etc/default/openvpn
```
You'll need root privileges again to edit this.

Finally we need to configure the new DNS servers. Chances are, your VPN provider either has statically assigned name servers in their `.ovpn` files, or [provides you with relevant IP addresses](https://support.nordvpn.com/Other/1047409702/What-are-your-DNS-server-addresses.htm); if not, a simple Google search will yield free public DNS servers.

On some distributions, editing `/etc/resolv.conf` is enough to reconfigure the DNS servers (note this has to be done as root, first executing `chattr -i /etc/resolv.conf`); but that does not seem to work for me anymore. The configuration file gets rewritten by some network daemon, thus doesn't hold permanently (if at all). Instead, we edit
```bash
/etc/dhcpcd.conf
```
and add the line
```
static domain_name_servers=DNS_IP1 [DNS_IP2 ...]
```
with the relevant DNS IP addresses. Finally, restart the DHCP service and (re)start OpenVPN
```bash
sudo service dhcpcd restart
sudo service openvpn (re)start
```
You can verify the VPN is working using, e.g.
```
pi@eidolon:~ $ curl ipinfo.io
{
  "ip": "5.253.206.172",
  "city": "Włochy",
  "region": "Mazovia",
  "country": "PL",
  "loc": "52.1961,20.9323",
  "org": "AS9009 M247 Ltd",
  "postal": "02-231",
  "timezone": "Europe/Warsaw",
  "readme": "https://ipinfo.io/missingauth"
}
```
Something I've noticed with the automated start of OpenVPN is that having multiple `.conf` files in `/etc/openvpn/` can cause some anomalous behaviour, especially on more recent versions of linux, including a highly annoying systemd password manager writing to `Wall` sporadically; make sure you only have **one** in the directory!

### Configuring Transmission <a name="configuring-transmission"></a>
The configuration settings for the transmission daemon can be found in `/etc/transmission-daemon/settings.json`. Lines of importance are
```
{
	// ...
	"download-dir": "/var/lib/transmission-daemon/downloads",
	// ...
	"rpc-password": "{20eb240695a406a6c62c80db858c4558eaea2146xL3ZaOo.",
	// ...
	"rpc-username": "transmission",
	// ...
	"speed-limit-down": 2,
	"speed-limit-down-enabled": true,
	"speed-limit-up": 100,
	"speed-limit-up-enabled": false,
	// ...
	"umask": 18,
	// ...
}
```
Before editing, ensure the daemon is not running `sudo service transmission-daemon stop`, else the changes will be reverted on reload.

Change username and password to whatever your preference is (alternative disable authentication entirely); the password will be changed to a hash value once the daemon is reloaded. Default username:password is `transmission:transmission`.

You can change the download directory here aswell, and it's worth changing `speed-limit-down` to something a little more convenient, e.g. 100. I would not recommend disabling it, as anyone watching your traffic would suddenly become aware of a bandwidth spike and probably suspect torrenting behaviour! Similarly, you'll be a bit of a cunt to your housemates.

You can also change the seeding speed limits here -- if you do, remember to change the `speed-limit-up-enabled` to `true`.

Finally `umask` is set to `18`, as transmission creates a new user with `uid 18`, which owns all of the downloaded files in order to sandbox them. If you want to be a bit risky, change it to your `uid` (probably `2`) so you don't have to `sudo chown pi:pi` all the time.

Restart the service `sudo service transmission-daemon start`. You can control the daemon using `transmission-remote {args}`, but, unless you disabled authentication, you'll always have to provide a login flag. As such, I recommend aliasing
```
alias tsm='transmission-remote --auth [transmission-user]:[transmission-pw]'
```
to save your fingers.

You can easily find a reference manual on the available commands. I found the most useful are
```
tsm -a "[uri]"			# append uri to queue
tsm -l 				# list current torrents
tsm -t {id}	-s/S 		# torrent with {id} should be {-s}topped or {-S}tarted.
tsm -t all {command}		# apply command to all torrents in list
tsm -t all -r 			# remove all torrents
```
NB: removing all torrents only removes their index from the daemon; the downloaded files will have to manually deleted.

With this you're now all set to start torrenting securely over a VPN.

### `elinks` for browsing torrent databases <a name="elink-config"></a>
You'll be able to access websites normally blocked by your ISP just by using `elinks` through the VPN, but to make torrenting a little easier it's worth creating a script for passing magnet URIs directly to transmission with a keybinding.

To do so, we create a bash script e.g. `~/scripts/magnet`, with contents
```
#!/bin/bash
patrn='\/(magnet.*)'		# regex for extracting magnet from a URI
[[ $1 =~ $patrn ]]
transmission-remote --auth [transmission-user]:[transmission-pw] -a "${BASH_REMATCH[1]}"
```
Then `sudo chmod +x ~/scripts/magnet` to make it executable.

Open `elinks`, press `esc` once followed by `o` to bring up the configuration menu. Navigate to `Document`, hit `space`, and then under `URI-passing` add a new option with value
```
/home/pi/scripts/magnet %c
```
save, and then close. Press `k` to open up keybindings, and now under `Main mapping` scroll down until you find `Pass URI of current link to external command` (careful, there are a few similarly named options which you may mistake -- I did). Add any key combination you like, e.g. just `p`, save and close. Exit `elinks` by pressing `q`.

You're now all set to automatically add magnet URIs to transmission without having to leave the browser, by hovering over a magnet URI and pressing your key binding (`p`).

### Allowing SSH behind OpenVPN <a name="ssh-config"></a>
If you want remote (i.e. not LAN) access to the raspi, you'll have to reroute network traffic correctly, such that external traffic coming to the `eth0` interface is correctly rerouted back through `eth0`. If this isn't done, the pi tries to send back responses across `tun0`, since OpenVPN completely reconfigures the pi's networking when active.

The fix for this is a little hacky, but it works well enough. Barebones, all that is required is a script
```
#!/bin/bash

(date; set; echo) >> /tmp/firewall.log

# check if openvpn is already active, if so stop and restart
ptrn="Active: active"
startvpn=0
if [[ $(sudo service openvpn status |grep Active:) =~ $ptrn ]]; then
	echo "vpn online" >> /tmp/firewall-preup.log
	startvpn=1
fi
sudo service openvpn stop

sudo ip rule add fwmark 66 table 666
sudo ip route add default via 192.168.0.1 dev eth0 table 666
sudo ip route flush cache
sudo iptables -t mangle -A OUTPUT -p tcp --sport 22 -j MARK --set-mark 66
sudo iptables -A INPUT -i tun0 -p tcp -m tcp --dport 22 -j DROP

if [[ "$startvpn" == "1" ]]; then
	sudo service openvpn start
fi
```
which you can save as e.g. `~/scripts/firewall-config` and make executable as root with 
```
sudo chown root:root ~/scripts/firewall-config && sudo chmod 4755 ~/scripts/firewall-config
``` 
Note, you don't need those echoes; I use them just to make sure the script is being executed correctly.

What this script does is disable OpenVPN, create a new table for traffic with marker `66`, and configure the firewall. The new table uses the gateway of your home router, normally `192.168.0.1` for `eth0`, instead of the OpenVPN gateway. We then flush the arp cache to have an unambigious gateway setup.

As incoming traffic on the native interface is unaffected by the OpenVPN, we mark the outgoing traffic with marker `66` on the SSH port, and drop all incoming SSH `tcp` traffic on `tun0` to prevent interface confusion.

If the OpenVPN service was already started (which it probably was), the last check starts the service again now that the traffic is correctly configured.

If you port forward on your home router now to the raspi, you'll have remote access.

#### Configure firewall on startup
I tried making this script run in `/etc/network/if-pre-up.d/` and `/etc/network/if-up.d/` but it was unable to correctly configure before OpenVPN spawns its service, so required one manual stop/start of the VPN before remote connection was allowed.

The solution I settled on was to create a `systemd` service, by creating the file `/etc/systemd/system/firewall-config.service`, with the following content
```
[Unit]
Description=Firewall configuration for SSH behind VPN
After=network.target

[Service]
Type=simple
User=pi
ExecStart=/bin/bash /home/pi/bin/firewall-config

[Install]
WantedBy=multi-user.target
```
and then executing
```
sudo systemctl enable firewall-config
```
to ensure the service is executed on startup.

If you followed to here, just reboot and your raspi is all set and ready.


### Useful scripts <a name="useful-scripts"></a>
This is specifically for the NordVPN `.ovpn` configuration files for `tcp` VPN. To make changing country a little bit easier, without leaving the transmission daemon torrenting in the background, I created this little script as `~/scripts/cvpn`:
```
#!/bin/bash
checkIP=0

while getopts "c" opt
do
	case "$opt" in
		c)
			checkIP=1
			;;
		?)
			echo "Usage: cvpn [-c] server-extension"
			exit 1
	esac
done

TSM='transmission-remote --auth [transmission-user]:[transmission-pw]'
shift $(expr $OPTIND - 1 )

echo "Stopping active transmissions..."
$TSM -t all -S
echo "Copying $1 configuration file..."
sudo /etc/openvpn/copy.sh $1
echo "Restarting openvpn service..."
sudo service openvpn restart 

if [ $checkIP -eq 1 ]; then
	echo "Fetching IP information..."
	sleep 6									# approx how long it takes for vpn to setup
	curl ipinfo.io
	echo ""
fi

echo "(Re)Starting active transmissions..."
$TSM -t all -s
```
Using `-c` will print the location of the VPN server so you can be sure it worked correctly, and the `server-extension` for NordVPN would be e.g. `uk18`. 

This script also requires `copy.sh` in `/etc/openvpn/`, and the `.ovpn` files in the directory `/etc/openvpn/nordtcp/`. The script is as follows
```
#!/bin/bash
cp /etc/openvpn/nordtcp/$1.nordvpn.com.tcp.ovpn /etc/openvpn/client.conf
sed -i -e 's/auth-user-pass/auth-user-pass .secrets/g' /etc/openvpn/client.conf
```
