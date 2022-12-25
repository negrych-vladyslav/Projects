FROM node:16.14.2-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh

WORKDIR /usr/src/app
COPY ./package.json ./
RUN npm install
COPY ./. .
EXPOSE 50051
CMD ["npm","run","start"]
