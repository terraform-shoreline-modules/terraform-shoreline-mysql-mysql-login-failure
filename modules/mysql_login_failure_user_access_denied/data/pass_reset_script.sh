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