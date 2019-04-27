# install-odoo
odoo-install.sh is a BASH shell script that automates the step-by-step instructions for installing and configuring a odoo server.

the speed of installation depending on your server and network speed,
but the installation take 10 minutes as average time.

<h3>Requirements</h3>
<ul>
   <li>Ubuntu 64-bit OS running Linux - this script tested on ubuntu 16.4.</li>
	 <li>CPU X64</li>
	 <li>2 GB of memory with swap enabled (4 GB of memory is better).</li>
	 <li>2 CPU cores (4 is better or more).</li>
	 <li>TCP ports 80, if behind firewall.</li>
	 <li>TCP ports 443, if you behind firewall.</li>
</ul>
<h3>Features</h3>
   <li>Support odoo versions (10, 11 ,12)</li>
	 <li>the configure with domain name</li>
	 <li>custom odoo port</li>
	 <li>custom postgresql password</li>
	 <li>custom odoo admin password</li>
	 <li>support SSL encryption using (let's encrypt)</li>
<h3>Getting ready</h3>
<ol>
   <li>Download the install-odoo.sh script</li>
   <li>Change the script permission <code>sudo chmod +x install-odoo.sh</code>  </li>
   <li>Run the script as root <code>./install-odoo.sh -h</code></li>
   <li>select odoo version you want to install</li>
</ol>
<h3>Usage</h3>
<ul>
   <li>Select your odoo version you want to install (ver 10 as example)</li>
	                     <code>./install-odoo.sh -v 10 </code>
	 <li>specific port (port 8070 as example)</li>
	                     <code>./install-odoo.sh -v 10 -r 8070 </code><br> Note: if you not specific the port,the script will chose the port 8069 as default.
	 <li>specific postgresql password.</li>
	                     <code>./install-odoo.sh -v 10 -p sql123 </code><br> Note: if you not specific the postgresql password,the script will chose the empty password as default.
	 <li>specific odoo admin password.</li>
	                      <code>./install-odoo.sh -v 10 -P admin123 </code><br> Note: if you not specific the admin password,the script will chose the empty password as default.
	 <li>Configure domain name with nginx server</li>
	                      <code>./install-odoo.sh -v 10 -s odoo.example.com </code><br> Note: if you not specific the domain name,the script will configure odoo with external ip.
	 <li>Support SSL certificate</li>
	                       <code>./install-odoo.sh -v 10 -s odoo.example.com -e info@eample.com </code> <br>
												  Note: you can't support SSL without the domain name. <br>
													Note: SSL using the 4096-bit RSA keys.
</ul>
