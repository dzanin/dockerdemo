import asyncpg
import asyncio

conn = await asyncpg.connect(user='docker', password='docker', database='docker', host='docker')
values = await conn.fetch('''SELECT * FROM account''')
print(values)
await conn.close()