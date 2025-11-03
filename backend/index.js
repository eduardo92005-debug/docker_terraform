import http from 'http';
import PG from 'pg';
const {
  DB_USER: user,
  DB_PASSWORD: pass,
  DB_HOST: host,
  DB_PORT: db_port,
  DB_NAME: db_name,
  PORT
} = process.env;

const port = Number(PORT) || 8080;

const client = new PG.Client(
  `postgres://${user}:${pass}@${host}:${db_port}/${db_name}`
);

let successfulConnection = false;

client.connect()
      .then(() => { successfulConnection = true })
      .catch(err => console.error('Database not connected -', err.stack));

http.createServer(async (req, res) => {
  console.log(`Request: ${req.url}`);
  
  if (req.url === "/api") {
    res.setHeader("Content-Type", "application/json");
    res.writeHead(200);

    let result;

    try {
      result = (await client.query("SELECT * FROM users")).rows[0];
    } catch (error) {
      console.error(error)
    }

    const data = {
      database: successfulConnection,
      userAdmin: result?.role === "admin"
    }

    res.end(JSON.stringify(data));
  } else {
    res.writeHead(503);
    res.end("Internal Server Error");
  }

}).listen(port, () => {
  console.log(`Server is listening on port ${port}`);
});