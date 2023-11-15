import express from "express";
import clientRoutes from "./routes/clients.js";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();
const app = express();  // express app initialization
const PORT = process.env.PORT || 8080;
app.use(express.json());  // use json parser
app.use(cors());

app.use('/clients', clientRoutes);  // every client route begins with '/clients'

// app.listen(
//     PORT,
//     () => console.log(`API live on port http://localhost:${PORT}`)
// )

app.get('/', (req, res) => res.send('Hello from the clients API homepage'));

// mongodb connection
mongoose.set("strictQuery", false);
mongoose
    .connect(process.env.MONGODB_URI)
    .then(() => {
        app.listen(PORT,() => console.log(`API live on port http://localhost:${PORT}`));
        console.log('Connected to Mongo')})
    .catch((error) => console.error(error));