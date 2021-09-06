<h1>Deploy odoo 12 on ubuntu 18.4</h1>

<h3>Installation Requirement</h3>
<ul>
  <li>VPS Server</li>
  <li>Make Sure you have Domain or subdomain and tied with server ip</li>
  <li>open ports [80, 443, 8069] if your server behind firewall</li>
</ul>

<h3>Befor you begin</h3>

<code>sudo apt update && sudo apt upgrade</code>

<h3>Install Server dependencies</h3>

<code>sudo apt install git nano python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less</code>

<h3>Create Odoo user</h3>
<code>sudo useradd -m -d /opt/odoo12 -U -r -s /bin/bash odoo12</code>

<h3>Install and Configure PostgreSQL</h3>
<code>sudo apt install postgresql</code>
<br><br>
<code>sudo su - postgres -c "createuser -s odoo12"</code>

<h3>Install Wkhtmltopdf </h3>
<code>wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.bionic_amd64.deb</code>
<br><br>
<code>sudo apt install ./wkhtmltox_0.12.5-1.bionic_amd64.deb</code>

<h3>Install and Configure Odoo</h3>

<code>sudo su - odoo12</code>
<br><br>
<code>git clone https://www.github.com/odoo/odoo --depth 1 --branch 12.0 /opt/odoo12/odoo</code>
<br><br>
<code>python3 -m venv odoo-venv</code>
<br><br>
<code>source odoo-venv/bin/activate</code>
<br><br>
<code>source odoo-venv/bin/activate</code>
<br><br>
<code>pip3 install wheel</code>
<br><br>
<code>pip3 install -r odoo/requirements.txt</code>
<br><br>
<code>deactivate</code>
<br><br>
<code>mkdir /opt/odoo12/odoo-custom-addons</code>
<br><br>
<code>exit</code>
<br><br>
<code>sudo cp /opt/odoo12/odoo/debian/odoo.conf /etc/odoo12.conf</code>
<br><br>
<code>sudo nano /etc/odoo12.conf</code>
<br><br>

<pre>
 <code>
  [options]
  ; This is the password that allows database operations:
  admin_passwd = my_admin_passwd
  db_host = False
  db_port = False
  db_user = odoo12
  db_password = False
  addons_path = /opt/odoo12/odoo/addons,/opt/odoo12/odoo-custom-addons
 </code>
  <button type="button"></button>
</pre>
<br>
<p>Do not forget to change the <code>my_admin_passwd</code> to something more secure.</p>
<br><br>

<h3>Create a Systemd Unit File</h3>

<code>sudo nano /etc/systemd/system/odoo12.service</code>
<br>
<pre>
 <code>
  [Unit]
  Description=Odoo12
  Requires=postgresql.service
  After=network.target postgresql.service

  [Service]
  Type=simple
  SyslogIdentifier=odoo12
  PermissionsStartOnly=true
  User=odoo12
  Group=odoo12
  ExecStart=/opt/odoo12/odoo-venv/bin/python3 /opt/odoo12/odoo/odoo-bin -c /etc/odoo12.conf
  StandardOutput=journal+console

  [Install]
  WantedBy=multi-user.target
 
 </code>
</pre>

<pre>
 <code>
  sudo systemctl daemon-reload
  sudo systemctl start odoo12
 </code>
</pre>
<br>

<p>Check the service status with the following command:</p><br>

<code>sudo systemctl status odoo12</code><br><br>

<pre>
 <code>
  * odoo12.service - Odoo12
   Loaded: loaded (/etc/systemd/system/odoo12.service; disabled; vendor preset: enabled)
   Active: active (running) since Tue 2018-10-09 14:15:30 PDT; 3s ago
 Main PID: 24334 (python3)
    Tasks: 4 (limit: 2319)
   CGroup: /system.slice/odoo12.service
           `-24334 /opt/odoo12/odoo-venv/bin/python3 /opt/odoo12/odoo/odoo-bin -c /etc/odoo12.conf

 </code>
</pre><br>

<code>sudo systemctl enable odoo12</code><br>

<h3>Test the Installation</h3>
<p>
 Open your browser and type: http://<your_domain_or_IP_address>:8069
 Assuming the installation is successful, a screen similar to the following will appear:
</p>
  
  <img src="https://raw.githubusercontent.com/Sherif-khaled/install-odoo/2.0/odoo-test.webp"><br><br>
  
  <h3>Configure Nginx as SSL and proxy</h3><br>
  
  <code>sudo apt install nginx certbot</code><br>
  <code>sudo systemctl stop nginx</code><br>
  
  <pre>
    <code>
      sudo /usr/bin/certbot certonly --standalone -d Your_Domain_Name --preferred-challenges http --agree-tos -n -m Your_Email --keep-until-expiring
    </code>
  </pre><br>
  
  <code>sudo nano /etc/nginx/sites-enabled/example.com</code><br>
  
  <pre>
    <code>
upstream oddo {
    server 127.0.0.1:8069;
}

server {
    listen      443 default;
    server_name yourOdooSite.com;

    access_log  /var/log/nginx/oddo.access.log;
    error_log   /var/log/nginx/oddo.error.log;

    ssl on;
    ssl_certificate     /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    keepalive_timeout   60;

    ssl_ciphers             HIGH:!ADH:!MD5;
    ssl_protocols           SSLv3 TLSv1;
    ssl_prefer_server_ciphers on;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://oddo;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            $host;
        proxy_set_header    X-Real-IP       $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }

    location ~* /web/static/ {
        proxy_cache_valid 200 60m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://oddo;
    }
}

server {
    listen      80;
    server_name yourOdooSite.com;

    add_header Strict-Transport-Security max-age=2592000;
    rewrite ^/.*$ https://$host$request_uri? permanent;
}
    </code>
  </pre><br><br>
  
  <code>sudo systemctl restart nginx</code><br>
  
  <code>sudo nano /etc/odoo12.conf</code><br>
  
  <code>proxy_mode = True</code><br>
  
  <code>sudo systemctl restart odoo12</code><br>
  
  
  
  
  
  
  
