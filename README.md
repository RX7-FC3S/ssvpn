# Shadowsocks with v2ray-plugin

This project uses Shadowsoks and v2ray-plugin to build a proxy server on Linux. ( The following installation and usage instructions are based on Ubuntu 20.04)

# Installation & Usage
### Install shadowsocks-libev

```bash
apt install shadowsocks-libev
```

### Edit the configuration:
```bash
vim /etc/shadowsocks-libev/config.json
```
- Set the "server" to "0.0.0.0", which allows all clients to connect to this server.
- Replace the "password" with a memberable one.
```json
{
  "server": "0.0.0.0",
  "mode": "tcp_and_udp",
  "server_port": 8388,
  "local_port": "1080",
  "password": "***",
  "timeout": "86400",
  "method": "chacha20-ietf-poly1305"
}
```

### Make v2ray-plugin executable
```bash
chmod +x v2ray-plugin
```

### Issue a SSL certificate
v2ray-plugin uses TLS to encrypt the network flow, so you need a SSL certificate. You can use the .acme.sh to do this, and it is free.

1. Install acme.sh
```bash
curl https://get.acme.sh | sh
```

2. Add environment variables

```bash
vim .bashrc
```

```bash
export CF_Email="example@gmail.com"
export CF_Key="***"
```

3. Register your acme.sh account

```bash
acme.sh --register-account -m example@gmail.com
```

4. Issue the certificate

```bash
acme.sh  --issue --dns dns_cf -d yourdomain.com
```

5. Find ca files in .acme.sh/yourdomain.com_ecc


## Edit the startup script
```bash
#!/bin/bash

SS_CONFIG="/etc/shadowsocks-libev/config.json"

HOST="yourdomain.com"
PORT=443

CER_PATH="../.acme.sh/yourdomain.com_ecc/yourdomain.com.cer"
KEY_PATH="../.acme.sh/yourdomain.com_ecc/yourdomain.com.key"

LOG_FILE="./ssv.log"

# You don't have to eidt the following code.
PLUGIN="./v2ray-plugin"
PLUGIN_OPTS="server;tls;host=$HOST;cert=$CER_PATH;key=$KEY_PATH"
...
```
## Run the startup.sh 
```bash
chmod +x startup.sh
./startup.sh
```


