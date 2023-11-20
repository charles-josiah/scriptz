
### This code establishes a connection to the MySQL server, retrieves the list of databases using SHOW DATABASES, 
### writes each database name to the changes.log file (separated by a newline character), and then closes the connection. 
### Make sure to replace "localhost", "username", and "password" with your actual connection details.

import pymysql

servername = "127.0.0.1"
username = "root"
password = "(cB=*>Pj#_2y6"

# Create connection
try:
    conn = pymysql.connect(host=servername, user=username, password=password)
    print("Connected successfully")

    # Retrieve and print list of databases
    cursor = conn.cursor()
    cursor.execute("SHOW DATABASES")
    databases = cursor.fetchall()

    print("Lista de  databases:")
    for db in databases:
        print(db[0])

    cursor.close()
    conn.close()

except pymysql.Error as e:
    print("Connection failed: " + str(e))
root@lnsicos-cadsol-hom:~# 
