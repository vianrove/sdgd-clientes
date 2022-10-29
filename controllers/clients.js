import ClientSchema from '../models/client.js';

export const getClients = (req, res) => {
    ClientSchema
        .find()
        .then((data) => res.json(data))
        .catch((error) => res.json({ message: error}))
};

export const getClient = (req, res) => {
    const { id } = req.params;
    ClientSchema
        .findOne({_id: id})
        .then((data) => res.json(data))
        .catch((error) => res.json({ message: error}))
};

export const createClient = (req, res) => {

    const client = ClientSchema(req.body);
    
    client
        .save()
        .then((data) => res.json(data))
        .catch((error) => res.json({ message: error}))
};

export const deleteClient = (req, res) => {
    const { id } = req.params;
    ClientSchema
        .remove({_id: id})
        .then((data) => res.json(data))
        .catch((error) => res.json({ message: error}))
};

export const updateClient = (req, res) => {
    const { id } = req.params;
    const {
        firstName,
        lastName,
        age,
        email,
        password,
        contactNumber
    } = req.body;
    
    ClientSchema
        .updateOne(
            {_id: id}, 
            { $set: {
                firstName,
                lastName,
                age,
                email,
                password,
                contactNumber                
            }})
        .then((data) => res.json(data))
        .catch((error) => res.json({ message: error}))
};
