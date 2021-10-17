#!/bin/bash

#First Useage
#Go to the following link in your browser:  
#https://accounts.google.com/o/oauth2/auth?client_id=123456789123-7n0vf5akeru7on6o2fjinrecpdoe99eg.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fdrive&state=state 
 
# vars
BACKUP_DIR=~/odoo_backups
ODOO_URL="Enter_Odoo_URL"
ODOO_DATABASE="Enter_Database_Name"
ADMIN_PASSWORD="Enter_Database_Password"

# create a backup directory
mkdir -p ${BACKUP_DIR}

CURRENTDATE=`date +"%Y-%m-%d"-%T`

# create a backup
curl -X POST \
    -F "master_pwd=${ADMIN_PASSWORD}" \
    -F "name=${ODOO_DATABASE}" \
    -F "backup_format=zip" \
    -o ${BACKUP_DIR}/${ODOO_DATABASE}.${CURRENTDATE}.zip \
    https://${ODOO_URL}/web/database/backup


#Upload backup to google drive
FILE=/usr/sbin/drive
if [ ! -f "$FILE" ]; then
    wget -O drive "https://drive.google.com/uc?id=0B3X9GlR6EmbnMHBMVWtKaEZXdDg"  
    mv drive /usr/sbin/drive  
    chmod 755 /usr/sbin/drive 
fi

drive upload --file "${BACKUP_DIR}/${ODOO_DATABASE}.${CURRENTDATE}.zip"

# delete old backups
find ${BACKUP_DIR} -type f -mtime +7 -name "${ODOO_DATABASE}.*.zip" -delete
