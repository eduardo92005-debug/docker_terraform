import http from 'http';
import PG from 'pg';

const {
  DB_USER: user,
  DB_PASSWORD: pass,
  DB_HOST: host,
  DB_PORT: db_port,
  DB_NAME: db_name,
  PORT,

} = process.env;

const port = Number(PORT) || 8080;

const client = new PG.Client(
  `postgres://${user}:${pass}@${host}:${db_port}/${db_name}`
);

let successfulConnection = false;

client.connect()
  .then(() => { successfulConnection = true })
  .catch(err => {
    if (process.env.ENVIRONMENT !== 'production') {
      console.error('Database not connected -', err.stack);
    }
  });

http.createServer(async (req, res) => {
  if (process.env.ENVIRONMENT !== 'production') {
    console.log(`Request: ${req.url}`);
  }

  try {
    if (req.url === "/api") {
      res.setHeader("Content-Type", "application/json");
      res.writeHead(200);

      const result = (await client.query("SELECT * FROM users")).rows[0] || {};

      const data = {
        database: successfulConnection,
        userAdmin: result?.role === "admin"
      };

      res.end(JSON.stringify(data));
    } else {
      res.writeHead(404);
      res.end();
    }
  } catch (error) {
    if (process.env.ENVIRONMENT !== 'production') {
      console.error('Unhandled error:', error);
    }
    res.writeHead(500);
    res.end();
  }

}).listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});
