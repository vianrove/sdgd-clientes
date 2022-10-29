import mongoose from "mongoose";

const Schema = mongoose.Schema

const ClientSchema = Schema({
    firstName: String,
    lastName: String,
    age: Number,
    id: String
})

mongoose.model('Client', ClientSchema)