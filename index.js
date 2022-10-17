import express from "express";
import bodyParser from "body-parser";
import clientRoutes from "./routes/clients.js";

const app = express();
const PORT = 8080;

app.use(bodyParser.json());

app.use('/clients', clientRoutes);

app.listen(
    PORT,
    () => console.log(`API live on port http://localhost:${PORT}`)
)

app.get('/', (req, res) => res.send('Hello from my api homepage'));

