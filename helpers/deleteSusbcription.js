import axios from "axios";

const deleteSubscription = (id) => {
    const url = `${process.env.PASARELA_API_URL}${id}`;
    
    // Delete assigned subscription
    axios
        .delete(url)
        .then(console.log("Subscription deleted successfully"))
        .catch((error) => {console.log(error)})
};

export default deleteSubscription;