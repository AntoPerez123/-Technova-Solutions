#!/bin/bash
set -euxo pipefail

yum update -y
yum install -y docker git mariadb105

systemctl start docker
systemctl enable docker
sleep 10

chmod 666 /var/run/docker.sock

mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

DB_HOST="${db_host}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"
DB_NAME="${db_name}"

mkdir -p /opt/app
cd /opt/app

cat <<'EOF' > server.js
const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
const port = 3001;

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
};

app.get('/', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT COUNT(*) as total FROM productos');
    await conn.end();
    res.send('Backend OK - productos: ' + rows[0].total);
  } catch (err) {
    res.status(500).send('Error DB: ' + err.message);
  }
});

app.listen(port, () => console.log('Backend en puerto ' + port));
EOF

cat <<'EOF' > package.json
{
  "name": "app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.2",
    "mysql2": "^3.6.0"
  }
}
EOF

cat <<'EOF' > Dockerfile.backend
FROM node:18
WORKDIR /app
COPY package.json .
RUN npm install
COPY server.js .
EXPOSE 3001
CMD ["node", "server.js"]
EOF

cat <<'EOF' > index.html
<!DOCTYPE html>
<html>
<head><title>TechNova</title></head>
<body>
<h1>Frontend funcionando</h1>
<p id="msg"></p>
<script>
fetch('/api')
  .then(r => r.text())
  .then(t => document.getElementById('msg').innerText = t)
  .catch(e => document.getElementById('msg').innerText = 'Error: ' + e);
</script>
</body>
</html>
EOF

cat <<'EOF' > Dockerfile.frontend
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

cat <<'EOF' > default.conf
server {
    listen 80;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }

    location /api {
        proxy_pass http://backend:3001/;
    }
}
EOF

cat <<EOF > docker-compose.yml
services:
  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
    environment:
      DB_HOST: $DB_HOST
      DB_USER: $DB_USER
      DB_PASSWORD: $DB_PASSWORD
      DB_NAME: $DB_NAME
    ports:
      - "3001:3001"

  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    volumes:
      - ./default.conf:/etc/nginx/conf.d/default.conf
    ports:
      - "80:80"
EOF

echo "Esperando RDS..."
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; do
  echo "RDS no disponible aún..."
  sleep 10
done

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" <<SQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;

CREATE TABLE IF NOT EXISTS productos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100)
);

INSERT INTO productos (nombre)
SELECT * FROM (
  SELECT 'Producto 1' UNION ALL
  SELECT 'Producto 2'
) tmp
WHERE NOT EXISTS (SELECT 1 FROM productos);
SQL

cd /opt/app
docker compose up -d

echo "APP OK"