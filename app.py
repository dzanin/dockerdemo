# import asyncio
# import asyncpg

# async def main():
#     # Establish a connection to an existing database named "test"
#     # as a "postgres" user.
#     conn = await asyncpg.connect(user='docker', password='docker', database='docker', host='localhost')
#     # Select a row from the table.
#     res = await conn.fetch('''SELECT * FROM account''')
#     # *row* now contains
#     # asyncpg.Record(id=1, name='Bob', dob=datetime.date(1984, 3, 1))
#     print(res)
#     # Close the connection.
#     await conn.close()
# asyncio.get_event_loop().run_until_complete(main())

import tornado.ioloop
import tornado.web

class MainHandler(tornado.web.RequestHandler):
    def get(self):
        self.write("Hello, world")

def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
    