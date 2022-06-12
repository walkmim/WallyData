import pyodbc
connection = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=wallydata.cluster-c3iie8ju3iaa.us-east-1.rds.amazonaws.com;DATABASE=teste;Uid=postgres;Pwd=WallDaat36587;')

cursor=connection.cursor()
#1
"""
cursor.execute("SELECT @@VERSION as version")
row = cursor.fetchone()
print(row.version)
"""

#2
"""
cursor.execute("SELECT nome,endereco FROM tb_cliente")
row = cursor.fetchall()
for rec in row:
    print(rec.nome,'>>>',rec.endereco)
"""

#3
#"""
cursor.execute("INSERT INTO tb_cliente (nome,endereco) VALUES ('Luiz Padilla','Rua maracatu, 10, Marica - RJ');")
cursor.commit()

cursor.execute("SELECT nome,endereco FROM tb_cliente")
row = cursor.fetchall()
for rec in row:
    print(rec.nome,'>>>',rec.endereco)
#"""

cursor.close()
connection.close()


#reference
#https://www.sqlnethub.com/blog/how-to-connect-to-sql-server-databases-from-a-python-program/
