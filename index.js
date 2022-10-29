import express from "express";
import clientRoutes from "./routes/clients.js";
import mongoose from "mongoose";
import dotenv from "dotenv";

dotenv.config();
const app = express();  // express app initialization
const PORT = process.env.PORT || 8080;

app.use(express.json());  // use json parser

app.use('/clients', clientRoutes);  // every client route begins with '/clients'

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