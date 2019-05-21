import asyncpg


con = await asyncpg.connect(user='docker',database='docker',password='docker' host='localhost',)
res=await con.fetchval('select * from account')
print(res)
await con.close()