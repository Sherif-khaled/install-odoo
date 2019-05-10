[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Documentation Status](https://readthedocs.org/projects/ansicolortags/badge/?version=latest)](http://ansicolortags.readthedocs.io/?badge=latest)

# install-odoo
odoo-install.sh is a BASH shell script that,will install and configure the odoo system,<br> without user interaction with the script<br>

the speed of installation depending on your server and network speed,<br>
but the installation take 10 minutes as average time.

<h2>Script Requirements</h2>
<ul>
   <li>Ubuntu 64-bit OS running Linux - this script tested on ubuntu 16.4.</li>
	 <li>CPU X64</li>
	 <li>2 GB of memory with swap enabled (4 GB of memory is better).</li>
	 <li>2 CPU cores (4 is better or more).</li>
	 <li>TCP ports 80, if behind firewall.</li>
	 <li>TCP ports 443, if you behind firewall.</li>
</ul>
<h2>Features</h2>
   <li>Support odoo versions (10, 11 ,12)</li>
	 <li>support the configure with domain name</li>
	 <li>option for custom odoo port</li>
	 <li>option for custom postgresql password</li>
	 <li>option for custom odoo admin password</li>
	 <li>option for choosing install wkhtmltopdf</li>
	 <li>option for choosing server type [apache/nginx]</li>
	 <li>support SSL encryption using (let's encrypt)</li>
	 <li>option for choosing RSA DH [2048/4069]bit</li>
	 <li>supoort rtlcss module for RTL UI</li>
<h2>Installation</h2>
<ol>
   <li>Download the install-odoo.sh script</li>
   <li>Change the script permission <code>sudo chmod +x install-odoo.sh</code>  </li>
   <li>Run the script as root <code>./install-odoo.sh -h</code></li>
   <li>select odoo version you want to install</li>
</ol>
<h2>Usage</h2>

<h4>elect odoo Version:-</h4>
<p>Select your odoo version you want to install (ver 10 as example)</p>
<code>./install-odoo.sh -v 10 </code>

<h4>Select odoo enterprise Version:-</h4>
<p>you must have github repository credential to install enterprise version</p>
<code>./install-odoo.sh -v 10 -e </code>

<h4>Installing with choosing port value:-</h4>
<p>you can select port between range [8060 - 8090],<br>except port 8072 becouse this port reserved for longpolling</p>
<code>./install-odoo.sh -v 10 -S odoo.example.com -r 8070</code>

<h4>Installing with choosing server type:-</h4>
<p>you can choosing the server type between [nginx - apache],<br>if you not choosing the server type the script will configure domain name with nginx server.</p>
<code>./install-odoo.sh -v 10 -S odoo.example.com -s apache</code>

<h4>Install With Hostname:-</h4>
<p>if you not specific the domain name,the script will configure odoo with external ip.</p>
<code>./install-odoo.sh -v 10 -S odoo.example.com </code><br>

<h4>Support SSL Certificat:-</h4>
<p>you can't support SSL without the domain name.</p>
<code>./install-odoo.sh -v 10 -S odoo.example.com -M info@eample.com </code><br>
<note>Note: SSL using the 2048-bit RSA keys by default.</note>

<h4>Support with choosing RSA-DH size:-</h4>
<code>./install-odoo.sh -v 10 -S odoo.example.com -M info@eample.com -K 4096</code><br>
<note>Note: SSL using the 2048-bit RSA keys by default.</note>

<h4>Installing with choosing Master Admin Password:-</h4>
<code>./install-odoo.sh -v 10 -S odoo.example.com -a admin123</code>

<h4>Installing with choosing postgresql user Password:-</h4>
<code>./install-odoo.sh -v 10 -S odoo.example.com -p sql123</code>

<h4>Installing with wkhtmltopdf:-</h4>
<code>./install-odoo.sh -v 10 -S odoo.example.com -w</code>

<h2>FAQ</h2>
<h4>Found a bug?</h4>
if you found a bug you can submit your bug here <a href="https://github.com/Sherif-khaled/install-odoo/issues/new">Submit Bug</a>
