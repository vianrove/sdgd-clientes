import express from "express";
import bodyParser from "body-parser";
import clientRoutes from "./routes/clients.js";
import mongoose from "mongoose";
import dotenv from "dotenv";

const variables = dotenv.config();
const app = express();
const PORT = process.env.PORT || 8080;

app.use(bodyParser.json());

app.use('/clients', clientRoutes);

app.listen(
    PORT,
    () => console.log(`API live on port http://localhost:${PORT}`)
)

app.get('/', (req, res) => res.send('Hello from my api homepage'));

// mongodb connection
mongoose
    .connect(process.env.MONGODB_URI)
    .then(() => console.log('Connected to Mongo'))
    .catch((error) => console.error(error));