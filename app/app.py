import psycopg2

conn = psycopg2.connect(host="localhost",database="docker", user="docker", password="docker")
cur = conn.cursor()

cur.execute('SELECT version()')

# display the PostgreSQL database server version
db_version = cur.fetchone()
print(db_version)

# close the communication with the PostgreSQL
cur.close()