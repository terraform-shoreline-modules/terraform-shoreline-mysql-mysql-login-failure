
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# "MySQL Login Failure - User Access Denied"
---

This incident type occurs when a user is unable to log in to a MySQL server due to an "access denied" error. This error typically indicates that there is an issue with the user's credentials or permissions, preventing them from accessing the server. This can be caused by a variety of factors, such as incorrect login credentials, expired passwords, or insufficient permissions for the user account. Resolving this issue typically involves troubleshooting the user's login details and ensuring that they have the necessary permissions to access the server.

### Parameters
```shell
export MYSQL_ADMIN="root"

export MYSQL_ADMIN_PASSWORD="PLACEHOLDER"

export MYSQL_USER="PLACEHOLDER"

export MYSQL_USER_PASSWORD="PLACEHOLDER"

export MYSQL_HOST="PLACEHOLDER"

export MYSQL_SERVER_IP_ADDRESS="PLACEHOLDER"

export MYSQL_POD_NAME="PLACEHOLDER"
```

## Debug

### Check the status of the MySQL pod(s) in the cluster
```shell
kubectl get pods -l app=mysql
```

### Verify that the MySQL server is running and accessible from within the cluster
```shell
kubectl exec -it ${MYSQL_POD_NAME} -- mysql -u ${MYSQL_USER} -p${MYSQL_USER_PASSWORD} -e "SELECT 1;"
```

### Check the logs of the MySQL pod(s) for any error messages related to user access
```shell
kubectl logs ${MYSQL_POD_NAME} | grep "access denied"
```

### Verify that the MySQL service account has sufficient permissions to access the server
```shell
kubectl exec -it ${MYSQL_POD_NAME} -- mysql -u ${MYSQL_USER} -p${MYSQL_USER_PASSWORD} -e "SHOW GRANTS FOR '${MYSQL_USER}'@'%';"
```

### Check MySQL user for expired password.
```shell
kubectl exec $MYSQL_POD -- mysql -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "SELECT Password_expired FROM mysql.user WHERE User='${MYSQL_USER}';"
```

### Check connectivity from the client to the MySQL server.
```shell
ping ${MYSQL_SERVER_IP_ADDRESS}
```

## Repair

### Check the user's login credentials to ensure that they are correct and have not been changed. If necessary, reset the user's password to ensure that they are using the correct login details.
```shell
bash

#!/bin/bash



# Define variables

MYSQL_USER=${MYSQL_USER}

MYSQL_USER_PASSWORD=${MYSQL_USER_PASSWORD}

MYSQL_HOST=${MYSQL_HOST}



# Check if user credentials are correct

mysql -u $MYSQL_USER -p$MYSQL_USER_PASSWORD -h $MYSQL_HOST -e "SELECT 1" > /dev/null 2>&1



if [ $? -eq 0 ]

then

  echo "User credentials are correct"

else

  echo "User credentials are incorrect. Resetting password..."



  # Reset user password

  mysql -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -h $MYSQL_HOST -e "ALTER USERNAME '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_USER_PASSWORD'; FLUSH PRIVILEGES;"

  

  echo "Password reset successful"

fi


```

### If necessary, grant additional permissions to the user to ensure that they have permissions to access the MySQL server.
```shell


#!/bin/bash



# 1. Retrieve the name of the user and the name of the MySQL pod from the command line arguments

MYSQL_USER=${MYSQL_USER}

MYSQL_POD=${MYSQL_POD_NAME}



# 2. Check the user's permissions on the MySQL server

kubectl exec $MYSQL_POD -- mysql -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "SHOW GRANTS FOR '$MYSQL_USER';"



# 3. If the user does not have sufficient permissions, grant them the necessary access

kubectl exec $MYSQL_POD -- mysql -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;"


```