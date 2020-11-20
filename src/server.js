// Generated by CoffeeScript 2.5.1
(function() {
  module.exports = function(type) {
    var Chunk, Convert, app, config, convert, express, fs, http, io, mineflayer, opn, request, server, sf, socketInfo, vec3;
    //biblioteki
    opn = require("opn");
    fs = require("fs");
    config = JSON.parse(fs.readFileSync(__dirname + "/../config.json"));
    http = require("http");
    express = require('express');
    app = express();
    server = http.createServer(app);
    io = require("socket.io")(server);
    request = require('request');
    mineflayer = require('mineflayer');
    Chunk = require("prismarine-chunk")(config.realServer.version);
    vec3 = require("vec3");
    Convert = require('ansi-to-html');
    convert = new Convert();
    //początkowe zmienne
    sf = {};
    socketInfo = {};
    //Konfiguracja serwera express
    if (type === "production") {
      app.use(express.static(__dirname + "/dist/"));
    } else {
      app.use(express.static(__dirname + "/client/"));
    }
    app.use(function(req, res, next) {
      res.set('Cache-Control', 'no-store');
      return next();
    });
    server.listen(config["port"], function() {
      return console.log(`Server is running on \x1b[34mhttp://localhost:${config["port"]}\x1b[0m`);
    });
    // opn("http://#{config.host}:#{config['express-port']}")

    //websocket
    return io.sockets.on("connection", function(socket) {
      var bot;
      socketInfo[socket.id] = {};
      bot = socketInfo[socket.id];
      return socket.on("initClient", function(data) {
        var botEventMap, emit, i, inv, results, socketEventMap;
        console.log("[\x1b[32m+\x1b[0m] " + data.nick);
        //Dodawanie informacji o graczu do socketInfo
        socketInfo[socket.id] = data;
        socketInfo[socket.id].bot = mineflayer.createBot({
          host: config.realServer.ip,
          port: config.realServer.port,
          username: socketInfo[socket.id].nick,
          version: config.realServer.version
        });
        bot = function() {
          return socketInfo[socket.id].bot;
        };
        emit = function(array) {
          return io.to(socket.id).emit(...array);
        };
        //Eventy otrzymywane z serwera minecraftowego
        bot()._client.on("map_chunk", function(packet) {
          var cell;
          cell = new Chunk();
          cell.load(packet.chunkData, packet.bitMap, false, true);
          emit(["mapChunk", cell.sections, packet.x, packet.z, packet.biomes]);
        });
        botEventMap = {
          "move": function() {
            emit(["move", bot().entity.position]);
          },
          "health": function() {
            emit(["hp", bot().health]);
            emit(["food", bot().food]);
          },
          "spawn": function() {
            emit(["spawn", bot().entity.yaw, bot().entity.pitch]);
          },
          "kicked": function(reason, loggedIn) {
            emit(["kicked", reason]);
          },
          "message": function(msg) {
            emit(["msg", convert.toHtml(msg.toAnsi())]);
          },
          "experience": function() {
            emit(["xp", bot().experience]);
          },
          "blockUpdate": function(oldb, newb) {
            emit(["blockUpdate", [newb.position.x, newb.position.y, newb.position.z, newb.stateId]]);
          }
        };
        for (i in botEventMap) {
          socketInfo[socket.id].bot.on(i, botEventMap[i]);
        }
        inv = "";
        socketInfo[socket.id].int = setInterval(function() {
          var inv_new;
          inv_new = JSON.stringify(bot().inventory.slots);
          if (inv !== inv_new) {
            inv = inv_new;
            emit(["inventory", bot().inventory.slots]);
          }
        }, 100);
        socketEventMap = {
          "move": function(state, toggle) {
            bot().setControlState(state, toggle);
          },
          "command": function(com) {
            bot().chat(com);
          },
          "rotate": function(data) {
            bot().look(...data);
          },
          "disconnect": function() {
            try {
              clearInterval(socketInfo[socket.id].int);
              console.log("[\x1b[31m-\x1b[0m] " + socketInfo[socket.id].nick);
              socketInfo[socket.id].bot.end();
              delete socketInfo[socket.id];
            } catch (error) {}
          }
        };
        results = [];
        for (i in socketEventMap) {
          results.push(socket.on(i, socketEventMap[i]));
        }
        return results;
      });
    });
  };

}).call(this);
