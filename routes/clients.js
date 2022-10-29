import express from "express";
import { 
    createClient, 
    getClient, 
    getClients,
    deleteClient,
    updateClient,
} from "../controllers/clients.js";

const router = express.Router();

// all routes here start with /clients  ex: /clients/getClient
router.get('/', getClients)

router.post('/', createClient);

router.get('/:id', getClient);

router.delete('/:id', deleteClient);

router.put('/:id', updateClient);

export default router;