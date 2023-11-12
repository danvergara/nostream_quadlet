Deploying a Nostream Relay using Podman and Quadlet
==========

## Dependencies:

* Podman v4.4 or higher (Quadlet is included as of this version)
* Nginx

## Installation:

Quadlet supports these unit file types:

* **.container**: Used to manage containers by running podman run
* **.kube**: Used to manage containers defined in Kubernetes YAML files by running podman kube play
* **.network**: Used to create Podman networks that may be referenced in .container or .kube files
* **.volume**: Used to create Podman volumes that may be referenced in .container files.

Everything you need is under the `systemd/` directory.

## Setup VM
Choose your preferred VM provider - whether you prefer Linode, Digital Ocean, AWS, GCP, Azure, etc.

### CLI Commands

Make sure you run Podman in rootless (this guide assumes you're running in this mode).
There's a `Makefile` file to avoid mistakes since copy and pasting commands is error prone.

Set up the environment.

```
sudo apt install nginx certbot python3-certbot-nginx -y

git clone https://github.com/danvergara/nostream_quadlet.git

cd nostream_quadlet
```

Generate `Podman` secrets

```
export NOSTREAM_CACHE_PASSWORD=foo
export NOSTREAM_DB_PASSWORD=foo
export NODELESS_API_KEY=bar
export NODELESS_WEBHOOK_SECRET=bar

make secrets
```

Copy the files to `$(HOME)/.config/containers/systemd ` 

If it's paid relay, run `cp-systemd-paid`, which copies every Quadlet file, except the
`nostream-public-configmap.yml` file.

```
make cp-systemd-paid
```

Otherwise, run `cp-systemd-public`, which copies every Quadlet file, except the `nostream-configmap.yml` file.

Force the generator by calling:

```
make reload
```

Start the service by calling:

```
make start
```

Note: If something goes wrong, systemd may not be able to tell you what is wrong with your unit file. You can use `/usr/libexec/podman/quadlet --dryrun` to see if there is an issue in the unit file.

```
make quadlet-dry-run
```

## Configure Nginx as a Reverse Proxy

Copy the content of the provided Nginx configuration file to the server configuration file.

```
cp nostream_quadlet.conf /etc/nginx/conf.d/nostream-quadlet.conf
```

```
server {
  listen 80;
  listen [::]:80;
  server_name <subdomain.domain.com>;

  error_log /var/log/nginx/nostream-quadlet.error;

  location / {
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Host $host;
      proxy_pass http://127.0.0.1:8008;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
  }
}
```
Don't forget to add your domain.

Verify the syntax and test Nginx for configuration errors.

```
sudo nginx -t
```

Restart Nginx to load changes.

```
sudo service nginx restart
```

### Configure HTTPS Access

Request SSL cert from letsencrypt/certbot
```
sudo certbot --nginx -d subdomain.mydomain.com
```
