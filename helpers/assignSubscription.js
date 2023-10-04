import axios from "axios";

const assignSubscription = (id) => {
    const url = process.env.PASARELA_API_URL;
    const  data = {
        _id: id,
        subStatus: false
    }
    // Create a new subscription in a different schema
    axios
        .post(url,data)
        .then(console.log("Subscription assigned successfully"))
        .catch((error) => {console.log(error)})
}

export default assignSubscription;