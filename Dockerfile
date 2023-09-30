# Base docker image
FROM node:18.18-alpine

# Sets up the workdire in the container
WORKDIR /app

# Copy repo files from local machine to container filesystem into a given directory
COPY . /app

# Executes command in the container to install dependencies
RUN npm install

# Executes the given command every time the container is initialized
CMD [ "npm", "start" ]