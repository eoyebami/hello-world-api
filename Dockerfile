FROM node:16

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY hello-world/. .

RUN npm install

EXPOSE 8888

CMD ["npm","start"]