

#!/bin/bash



# 1. Retrieve the name of the user and the name of the MySQL pod from the command line arguments

MYSQL_USER=${MYSQL_USER}

MYSQL_POD=${MYSQL_POD_NAME}



# 2. Check the user's permissions on the MySQL server

kubectl exec $MYSQL_POD -- mysql -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "SHOW GRANTS FOR '$MYSQL_USER';"



# 3. If the user does not have sufficient permissions, grant them the necessary access

kubectl exec $MYSQL_POD -- mysql -u ${MYSQL_ADMIN} -p${MYSQL_ADMIN_PASSWORD} -e "GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'%'; FLUSH PRIVILEGES;"