# web-minecraft

[![Join the chat at https://gitter.im/web-minecraft/community](https://badges.gitter.im/web-minecraft/community.svg)](https://gitter.im/web-minecraft/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Discord](https://img.shields.io/badge/chat-on%20discord-brightgreen.svg)](https://discord.gg/h6DQzDx2G7)

## About

**This is Minecraft client written in CoffeeScript using noa-engine.** From web browser this client connects to node.js server and then to real minecraft server, so you can play minecraft in the browser.

#### Installation
```bash
#Clone repo
git clone --branch noa-engine https://github.com/michaljaz/web-minecraft
cd web-minecraft

#Install node.js libraries
npm install

```
#### Development setup

```bash
#Start node server with webpack middleware
npm run dev

```

#### Production setup
```bash
#Cleaning dist folder
npm run clean

#Building app bundle
npm run build

#Start node server and serve bundle files
npm start

```

#### Screenshots

[<img src="https://i.ibb.co/fSrVNJs/Screenshot-from-2021-01-08-15-04-02.png" alt="Screenshot" width="100%">](https://i.ibb.co/fSrVNJs/Screenshot-from-2021-01-08-15-04-02.png)
