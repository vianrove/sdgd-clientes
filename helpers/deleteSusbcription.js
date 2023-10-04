import axios from "axios";

const deleteSubscription = (id) => {
    const url = `https://sdgd-pasarela.onrender.com/subscriptions/${id}`;
    
    // Delete assigned subscription
    axios
        .delete(url)
        .then(console.log("Subscription deleted successfully"))
        .catch((error) => {console.log(error)})
};

export default deleteSubscription;