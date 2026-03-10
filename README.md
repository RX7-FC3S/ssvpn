# Shadowsocks with v2ray-plugin and Nginx

This project demonstrates how to build a proxy server on Linux using **Shadowsocks-libev** with **v2ray-plugin** and **Nginx**.
> The following installation and usage instructions are based on Ubuntu 20.04

# Installation & Usage
## 1. Install and Configure Shadowsocks
### 1.1 Install shadowsocks-libev
```bash
apt update
apt install shadowsocks-libev
```

### 1.2 Configure shadowsocks
Edit the configuration file:
```bash
vim /etc/shadowsocks-libev/config.json
```

Set "server" to "127.0.0.1" to allow only local access (from Nginx):
```json
{
  "server": "127.0.0.1",
  "mode": "tcp_and_udp",
  "server_port": 8388,
  "local_port": "1080",
  "password": "your_password",
  "timeout": "86400",
  "method": "chacha20-ietf-poly1305",
  "plugin": "v2ray-plugin",
  "plugin_opts": "server;host=yourdomain.com;path=/your_path;"
}
```

## 2. Install v2ray-plugin
Download the binary and move it to the system path:
```bash
chmod +x v2ray-plugin
mv v2ray-plugin /usr/bin/
```

## 3. Issue an TLS certificate
`v2ray-plugin` uses TLS to encrypt network traffic, so an TLS certificate is required. You can obtain a free certificate using `acme.sh` with the **Cloudflare DNS API**.

### 3.1 Install acme.sh
```bash
curl https://get.acme.sh | sh
```

### 3.2 Add environment variables
Edit `.bashrc`:
```bash
vim ~/.bashrc
```

Add the following variables for **Cloudflare DNS API**:
```bash
export CF_Email="yourdomain@mail.com"
export CF_Key="***" # Global API Key
```

Reload the environment:
```bash
source ~/.bashrc
```

### 3.3 Register an acme.sh account
```bash
acme.sh --register-account -m yourdomain@mail.com
```

### 3.4 Issue the certificate
```bash
acme.sh --issue --dns dns_cf -d yourdomain.com
```

After issuing the certificate, the files will be located in:
```
~/.acme.sh/yourdomain.com_ecc/
```

## 4. Install and configure Nginx
### 4.1 Install Nginx:
```bash
apt install nginx -y
```

### 4.2 Create a configuration file:
```bash
vim /etc/nginx/conf.d/yourdomain.com.conf
```

Example configuration:
```nginx
server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /root/.acme.sh/yourdomain.com_ecc/yourdomain.com.cer;
    ssl_certificate_key /root/.acme.sh/yourdomain.com_ecc/yourdomain.com.key;

    root /var/www/html;
    index index.html index.htm;

    # Disable directory scanning
    location ~ /\. {
        deny all;
    }

    location /your_path {
        if ($http_upgrade != "websocket") {
            return 404;
        }

        proxy_redirect off;
        proxy_pass http://127.0.0.1:8388;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### 4.3 Validate the configuration and reload Nginx
Before applying the configuration, verify that the Nginx configuration file is valid:

```bash
nginx -t
```

If the test passes, reload Nginx to apply the changes:
```bash
nginx -s reload
```

## 5. Create `startup.sh` and run
Example `startup.sh`:
```bash
#!/bin/bash
nohup ss-server -c "/etc/shadowsocks-libev/config.json" > /dev/null 2>&1 &
```

Run `startup.sh`:
```bash
chmod +x startup.sh
./startup.sh
```

## Note:
- Replace your_password with a secure password.
- Replace yourdomain.com with your actual domain.
- Reloace yourdomain@mail.com with your actual eamil address.
- Replace /path with the WebSocket path used by v2ray-plugin.

