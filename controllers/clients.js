import { v4 as uuidv4 } from 'uuid';

let clients = []

export const getClients = (req, res) => {
    res.send(clients);
};

export const getClient = (req, res) => {
    const { id } = req.params;

    const clientFound = clients.find((client) => client.id === id);

    res.send(clientFound);
};

export const createClient = (req, res) => {

    const client = req.body;

    const clientWithId = { ...client, id: uuidv4() };

    clients.push(clientWithId);
    res.send(`${clientWithId.firstName} was added to the database`);
};

export const deleteClient = (req, res) => {
    const { id } = req.params;

    clients = clients.filter((client) => client.id != id);

    res.send(`${id} was deleted successfully`);
};

export const updateClient = (req, res) => {
    const { id } = req.params;

    const { firstName, lastName, age } = req.body;

    const clientToUpdate = clients.find(client => client.id == id);

    if(firstName) clientToUpdate.firstName = firstName;
    if(lastName) clientToUpdate.lastName = lastName;
    if(age) clientToUpdate.age = age;
    
    res.send(`User ${id} updated successfully`)
};
