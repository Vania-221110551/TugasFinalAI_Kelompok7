import mysql.connector

# Define mydb and mycursor as global variables
mydb = None
mycursor = None

def connect_database(name=None):
    global mydb, mycursor
    if name:
        mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            passwd="",
            database=name
        )
    else:
        mydb = mysql.connector.connect(
            host="localhost",
            user="root",
            passwd=""
        )
    mycursor = mydb.cursor()

def create_database(name): #--> buat database baru sesuai nama di parameter
  connect_database()
  mycursor.execute(f"CREATE DATABASE {name}")
  mycursor.execute("SHOW DATABASES")
  for x in mycursor.fetchall(): #--> jalankan kalau mau cek apakah databasenya sudah tertambah atau belum
    print(x)
  mydb.close()

def delete_database(name): #--> hapus database sesuai nama di parameter
  connect_database()
  mycursor.execute(f"DROP DATABASE {name}")
  mycursor.execute("SHOW DATABASES")
  for x in mycursor.fetchall(): #--> jalankan kalau mau cek apakah databasenya sudah terhapus atau belum
    print(x)
  mydb.close()

def create_table(name):
  mycursor.execute(f"CREATE TABLE {name}(id INT PRIMARY KEY, name VARCHAR(50), role VARCHAR(30))")
  mycursor.execute("SHOW TABLES")
  for x in mycursor.fetchall(): #--> jalankan jika mau mengecek apakah tabel sudah berhasil di create atau belum
    print(x)

def insert_data_to_table(table_name, id, name, role): 
  sql = f"INSERT INTO {table_name} (id, name, role) VALUES (%s, %s, %s)"
  val = (id, name, role)
  mycursor.execute(sql, val)
  mydb.commit()

def display_table_data(table_name):
  mycursor.execute(f"SELECT * FROM {table_name}")
  myresult = mycursor.fetchall()
  for x in myresult:
    print(x)

# Alur kerja databasenya
def main():
  # Buat database dengan nama 'Authorized_user'
  create_database("Authorized_user")
  # Connect ke database 'Authorized_user' yang sudah dibuat tadi
  connect_database("Authorized_user")
  # Buat tabel dengan nama 'my_table' di database 'students'
  create_table("my_table")


# delete_database("Authorized_user")

main()
