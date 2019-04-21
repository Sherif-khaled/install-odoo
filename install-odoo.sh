#!/bin/bash

USAGE(){
  cat 1>&2 <<HERE
  Installer script for setting up odoo system.

  This script support odoo Version (9 ,10 ,11 ,12), also this script
  supports installation on cloud host or localhost.

  USAGE:
      odoo-install.sh [OPTIONS]

  OPTIONS (Install odoo system):

      -v    <version>          Install given version of odoo (e.g. '10.0') [required]
      -m    <model>            Model of odoo system (e.g. 'community') [required]

      -p    <admin password>   Password for odoo administrator [recommended]
      -P   <sql password>     setup password for postgresql [recommended]
      -r <server port>      spsifec server port
      -h                       Print help

  OPTIONS (support SSL)
      -s    <hostname>         Configure server with <hostname> [required]
      -e    <email>            E-mail for Let's Encrypt certbot [required]

  EXAMPLES

     setup a odoo system

        .\install-odoo.sh -v 10.0 -m community
        .\install-odoo.sh -v 10.0 -m community -p admin123
        .\install-odoo.sh -v 10.0 -m community -p admin123 -sp sql123
        .\install-odoo.sh -v 10.0 -m community -p admin123 -sp sql123
        .\install-odoo.sh -v 10.0 -m community -p admin123 -sp sql123 -port 8069

  SUPPORT:
      Source: https://github.com/Sherif-khaled/install-odoo
      Commnity: https://odoo-community.org/

HERE
}

main(){

 HOST= get_ip
 PORT=8069
 PASS=''
 pp=''


 check_x64
 check_mem
 check_ubuntu 16.04

  while builtin getopts "hv:m:p:P:r:s:e:" opt "${@}"; do
    case $opt in
      h)
        USAGE
        exit 0
        ;;

      v)
        VERSION=$OPTARG
        check_version $VERSION
        ;;
      m)
        MODEL=$OPTARG
        check_model $MODEL
        ;;
      p)
        PASS=$OPTARG
        check_admin_pass $PASS
        ;;
      P)
        SQL_PASS=$OPTARG
        check_sql_pass $SQL_PASS
        ;;
      r)
        PORT=$OPTARG
        check_port $PORT
        ;;

      s)
        HOST=$OPTARG
        check_host $HOST
        ;;
      e)
        EMAIL=$OPTARG
        check_email $EMAIL
        ;;

      :)
        err "Missing option argument for -$OPTARG"
        exit 1
        ;;

      \?)
        err "Invalid option: -$OPTARG" >&2
        usage
        ;;
    esac
  done

  install_odoo

}



check_root() {
  if [ $EUID != 0 ]; then err "You must run this script as root."; fi
}

err(){
  echo "install-odoo.sh say: $1"
  exit 1
}
check_version(){
  ver=$1
  case $ver in
    9)
       VERSION=9
      ;;
    10)
       VERSION=10
      ;;
    11)
       VERSION=11
      ;;
    12 )
       VERSION=12
      ;;
    *)
       err "the script not supported this version $ver"
  esac

}
check_model(){
  model=''
  if [ -z $1 ];then
    err "please select odoo model"
  else
    if [ $1 = "community" ];then
       model='community'
    elif [ $1 = 'enterprise' ];then
       model='enterprise'
    else
      err "check the model spling"
    fi
  fi
}
check_admin_pass(){
  if [ -z $1 ];then
    err "please enter the admin password"
  fi
}
check_sql_pass(){
  if [ -z $1 ];then
    err "please enter the postgresql password"
  fi
}
check_port(){
  port=$1
  if [ $port -gt 8090 ] || [ $port -lt 8060 ];then
    err "the port number must be between [8060] and [8090]"
  fi
}
check_host(){
  if [ -z $1 ];then
    err "please enter your hostname"
  fi

  #RESOLVE="$(dig +short $HOST @resolver1.opendns.com)"
  #IP= get_ip

  #if [ "$RESOLVE" != "$IP" ]; then err "DNS lookup for $1 resolved to $DIG_IP but didn't match local $IP."; fi
}
check_email(){
  email=$1
  if [ -z $email ];then
    err "please enter your email"
  fi
}
check_mem() {
  MEM=`grep MemTotal /proc/meminfo | awk '{print $2}'`
  MEM=$((MEM/1000))
  if (( $MEM < 2048 )); then err "Your server needs to have (at least) 2G of memory."; fi
}

check_ubuntu(){
  RELEASE=$(lsb_release -r | sed 's/^[^0-9]*//g')
  if [ "$RELEASE" != $1 ]; then err "You must run this command on Ubuntu $1 server."; fi
}

check_x64() {
  UNAME=`uname -m`
  if [ "$UNAME" != "x86_64" ]; then err "You must run this command on a 64-bit server."; fi
}
get_ip(){
	myip="$(dig +short myip.opendns.com @resolver1.opendns.com)"
    host="${myip}"
    echo $host
}
check_apache(){
	if dpkg -l | grep -q apache2; then err "You must unisntall apache2 first"; fi
}
setup_nginx(){
	apt-get install nginx -y
	systemctl start nginx
	systemctl enable nginx

    ufw start
	ufw allow 'Nginx HTTP'

}
configure_nginx(){

	cat > /etc/nginx/sites-available/$HOST << HERE

upstream odoo {
    server 127.0.0.1:$PORT;
}

server {
    listen      80 default;
    server_name $HOST;

    access_log  /var/log/nginx/odoo.access.log;
    error_log   /var/log/nginx/odoo.error.log;

    proxy_buffers 16 64k;
    proxy_buffer_size 128k;

    location / {
        proxy_pass  http://odoo;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_redirect off;

        proxy_set_header    Host            \$host;
        proxy_set_header    X-Real-IP       \$remote_addr;
        proxy_set_header    X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto https;
    }

    location ~* /web/static/ {
        proxy_cache_valid 200 60m;
        proxy_buffering on;
        expires 864000;
        proxy_pass http://odoo;
    }
}
	
HERE

ln -s /etc/nginx/sites-available/$HOST /etc/nginx/sites-enabled/$HOST
rm -f /etc/nginx/sites-enabled/default
service nginx restart

}
upgrade_system(){
  echo -e "\n---- Update Server ----"
  apt update
  apt dist-upgrade -y
}
configure_ufw(){
  service ufw start
  ufw allow ssh
  ufw allow $PORT/tcp
  echo "y" | ufw enable $answer
}
install_dependencies(){

  declare -a dependencies=("git" "python-pip" "postgresql" "postgresql-server-dev-9.5"
                           "python-all-dev" "python-dev" "python-setuptools" "libxml2-dev"
                           "libxslt1-dev" "libsasl2-dev" "libldap2-dev" "pkg-config"
                           "libtiff5-dev" "libjpeg8-dev" "libjpeg-dev" "zlib1g-dev"
                           "libfreetype6-dev" "liblcms2-dev" "liblcms2-utils" "libwebp-dev"
                           "tcl8.6-dev" "tk8.6-dev" "python-tk" "libyaml-dev" "fontconfig")

  for (( i = 0; i < ${#dependencies[@]} ; i++ )); do
      printf "\n**** Installing: ${dependencies[$i]} *****\n\n"

      # Run each command in array
      eval "apt-get install ${dependencies[$i]} -y"


  done
}
create_user(){
  #create postgresql user
  #su - postgres
  #PGPASSWORD=Admin159# odoo$VERSION -U postgres
  #exit
  #create odoo user
  adduser --system --home=/opt/odoo$VERSION --group odoo$VERSION

}
configure_logs(){
  mkdir /var/log/odoo$VERSION
}
install_python_dependencies(){

  #install python dependencies
  pip install -r /opt/odoo$VERSION/doc/requirements.txt
  pip install -r /opt/odoo$VERSION/requirements.txt

  #Install Less CSS via Node.js and npm
  curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
  apt install -y nodejs
  npm install -g less less-plugin-clean-css

  #Install Stable Wkhtmltopdf
  cd /tmp
  wget https://downloads.wkhtmltopdf.org/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-amd64.deb
  dpkg -i wkhtmltox-0.12.1_linux-trusty-amd64.deb
  cp /usr/local/bin/wkhtmltopdf /usr/bin
  cp /usr/local/bin/wkhtmltoimage /usr/bin
}
create_odoo_config(){
  echo "[options]" >> /etc/odoo$VERSION-server.conf
  echo "admin_passwd = $PASS" >> /etc/odoo$VERSION-server.conf
  echo "db_host = False" >> /etc/odoo$VERSION-server.conf
  echo "db_port = False" >> /etc/odoo$VERSION-server.conf
  echo "db_user = odoo$VERSION" >> /etc/odoo$VERSION-server.conf
  echo "db_password = False" >> /etc/odoo$VERSION-server.conf
  echo "addons_path = /opt/odoo$VERSION/addons" >> /etc/odoo$VERSION-server.conf

  if [ $PORT -ne 0 ];then
    echo "xmlrpc_port = $PORT" >> /etc/odoo$VERSION-server.conf
  fi
}
create_odoo_service(){
  echo "[Unit]" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "Description=Odoo Open Source ERP and CRM" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "Requires=postgresql.service" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "After=network.target postgresql.service" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "[Service]" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "Type=simple" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "PermissionsStartOnly=true" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "SyslogIdentifier=odoo-server" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "User=odoo$VERSION" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "Group=odoo$VERSION" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "ExecStart=/opt/odoo$VERSION/odoo-bin --config=/etc/odoo$VERSION-server.conf --addons-path=/opt/odoo$VERSION/addons/" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "WorkingDirectory=/opt/odoo$VERSION/" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "StandardOutput=journal+console" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "[Install]" >> /lib/systemd/system/odoo$VERSION-server.service
  echo "WantedBy=multi-user.target" >> /lib/systemd/system/odoo$VERSION-server.service

}
odoo_server_configuration(){

  #Create Odoo configuration File
  create_odoo_config

  #Create an Odoo Service
  create_odoo_service

  #Change File Ownership and Permissions
  chmod 755 /lib/systemd/system/odoo$VERSION-server.service
  chown root: /lib/systemd/system/odoo$VERSION-server.service
  chown -R odoo$VERSION: /opt/odoo$VERSION/
  chown odoo$VERSION:root /var/log/odoo$VERSION
  chown odoo$VERSION: /etc/odoo$VERSION-server.conf
  chmod 640 /etc/odoo$VERSION-server.conf

}
install_odoo(){
  upgrade_system
  configure_ufw
  install_dependencies
  create_user
  configure_logs
  git clone https://www.github.com/odoo/odoo --depth 1 --branch $VERSION.0 --single-branch /opt/odoo$VERSION
  install_python_dependencies

  odoo_server_configuration

  if [ ! -z $HOST ];then
  	setup_nginx
  	configure_nginx
  fi

  test_the_server
  print_url
}
test_the_server(){
  systemctl start odoo$VERSION-server
  systemctl enable odoo$VERSION-server
  systemctl status odoo$VERSION-server
}
print_url(){

	if [ -z $HOST ];then
        EXTERNAL_IP= my_ip
    fi

    if [ -z "$EMAIL" ];then
  	    echo "http://$HOST"
  	elif [ -z $HOST ];then
  		echo "http://$EXTERNAL_IP"
    else   
  	    echo "https://$HOST"
    fi
}

main "$@" || exit 1
