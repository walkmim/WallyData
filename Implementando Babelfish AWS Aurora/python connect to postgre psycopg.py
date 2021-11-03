import psycopg2
connection = psycopg2.connect(host='wallydata.cluster-c3iie8ju3iaa.us-east-1.rds.amazonaws.com', database = 'babelfish_db', port='5432', 
user='postgres', password='WallDaat36587')
cursor = connection.cursor()

#1
"""
cursor.execute("SELECT VERSION() as version;")
row = cursor.fetchone()
print(row)
"""

#2
"""
cursor.execute("SELECT nome, endereco FROM teste_dbo.tb_cliente;")
row = cursor.fetchall()
for rec in row:
    print(rec[0],'>>>',rec[1])
"""

#3
#"""
cursor.execute("INSERT INTO dbo.tb_cliente (nome,endereco) VALUES ('Luan Carvalho','Rua Piracanjuba, 10, Curvelo - MG');")
connection.commit()

cursor.execute("SELECT nome,endereco FROM dbo.tb_cliente")
row = cursor.fetchall()
for rec in row:
    print(rec[0],'>>>',rec[1])
#"""

cursor.close()
connection.close()

#reference
#https://www.devmedia.com.br/como-criar-uma-conexao-em-postgresql-com-python/34079

