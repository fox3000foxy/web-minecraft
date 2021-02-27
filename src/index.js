var opn = require("open");
var fs = require("fs");
var config = JSON.parse(fs.readFileSync(`${__dirname}/server.json`));
var express = require("express");
var app = express();
var server = require("http").createServer(app);
var io = require("socket.io")(server);
var mineflayer = require("mineflayer");
var Chunk = require("prismarine-chunk")(config.version);
var vec3 = require("vec3");
var Convert = require("ansi-to-html");
var convert = new Convert();
var helmet = require("helmet");
var compression = require("compression");
var port = process.env.PORT || 8080;

app.use(
    helmet({
        contentSecurityPolicy: false,
    })
);

//SOCKET FOR INV
//     app.get('/inventory', (req, res) => {
//         var buffer = bot.inventory
//         fs.writeFileSync(db + './buffers/inventory.json', JSON.stringify(buffer))
//         res.status(200).sendFile(pathServer + `buffers/inventory.json`)
//     })
// app.get("/selectItem/:item", (req, res) => {
//         bot.equip(parseInt(req.params.item), "hand")
//         selectedItemType = req.params.item
//     })
//     app.get("/unsneak", (req, res) => {
//         bot.setControlState("sneak",false)
//     })
//     app.get("/sneak", (req, res) => {
//         bot.setControlState("sneak",true)
//     })
//     app.get("/equipItem/:item/:slot", (req, res) => {
//         if (req.params.item == "0") return
//         let slot;
//         switch (req.params.slot) {
//             case '5': slot = "head"; break;
//             case '6': slot = "torso"; break;
//             case '7': slot = "legs"; break;
//             case '8': slot = "feet"; break;
//         }
//         try { bot.equip(parseInt(req.params.item), slot) }
//         catch (e) { console.log(e) }
//     })
//     app.get("/unequipItem/:slot", (req, res) => {
//         let slot;
//         switch (req.params.slot) {
//             case '5': slot = "head"; break;
//             case '6': slot = "torso"; break;
//             case '7': slot = "legs"; break;
//             case '8': slot = "feet"; break;
//         }
//         //             console.log(req.params.slot)
//         //             console.log(slot)
//         try { bot.unequip(slot) }
//         catch (e) { console.log(e) }
//     })
//     app.get("/dropItem/:item", (req, res) => {
//         bot.toss(parseInt(req.params.item), 0, 1)
//     })
// 
//     app.get("/selectedItem", (req, res) => {
//         res.status(200).json(bot.quickBarSlot)
//     })
//     app.get("/invertItem/:item", (req, res) => {
//         //             bot.equip(parseInt(req.params.item),"hand")
//         //                 console.log(parseInt(req.params.item))
//         bot.equip(parseInt(selectedItemType), "off-hand")
//         selectedItemType = req.params.item
//     })
//     app.get("/scrollItem/:dir/:item", (req, res) => {
//         if (req.params.dir == "down")
//             bot.quickBarSlot += 1
//         else
//             bot.quickBarSlot -= 1
// 
//         bot.equip(parseInt(req.params.item), "hand")
//     })

app.use(compression());
var mode = process.argv[2];
if (mode === "production") {
    app.use(express.static(`${__dirname}/client/dist`));
} else if (mode === "development") {
    var webpack = require("webpack");
    var middleware = require("webpack-dev-middleware");
    var devconfig = require(`${__dirname}/client/webpack.dev.js`);
    var compiler = webpack(devconfig);
    app.use(middleware(compiler));
} else {
    console.log("Incorrect mode!");
}
server.listen(port, function () {
    opn(`http://localhost:${port}`);
    return console.log(`Server is running on \x1b[34m*:${port}\x1b[0m`);
});
var botByNick = {};
io.sockets.on("connection", function (socket) {
    var query = socket.handshake.query;
    var settings = query.nick.split('%C2%A7')
    console.log(settings)
    console.log(`[\x1b[32m+\x1b[0m] ${settings[0]}`);
    var heldItem = null;
    var bot = mineflayer.createBot({
        host: settings[1] || config.ip,
        port: settings[2] || config.port,
        username: settings[0].split("%C2%A7")[0],
        version: config.version,
    });
    botByNick[query.nick] = bot;
    bot._client.on("map_chunk", function (packet) {
        var cell = new Chunk();
        cell.load(packet.chunkData, packet.bitMap, true, true);
        socket.emit("mapChunk", cell.sections, packet.x, packet.z);
    });
    bot._client.on("respawn", function (packet) {
        socket.emit("dimension", packet.dimension.value.effects.value);
    });
    bot.on("heldItemChanged", function (item) {
        heldItem = item;
    });
    bot.on("login", function () {
        socket.emit("dimension", bot.game.dimension);
    });
    bot.on("move", function () {
        socket.emit("move", bot.entity.position);
    });
    bot.on("health", function () {
        socket.emit("hp", bot.health);
        socket.emit("food", bot.food);
    });
    bot.on("spawn", function () {
        socket.emit("spawn", bot.entity.yaw, bot.entity.pitch);
    });
    bot.on("kicked", function (reason) {
        socket.emit("kicked", reason);
    });
    bot.on("message", function (msg) {
        socket.emit("msg", convert.toHtml(msg.toAnsi()));
    });
    bot.on("experience", function () {
        socket.emit("xp", bot.experience);
    });
    bot.on("blockUpdate", function (oldb, newb) {
        socket.emit("blockUpdate", [
            newb.position.x,
            newb.position.y,
            newb.position.z,
            newb.stateId,
        ]);
    });
    bot.on("diggingCompleted", function (block) {
        socket.emit("diggingCompleted", block);
    });
    bot.on("diggingAborted", function (block) {
        socket.emit("diggingAborted", block);
    });
    var inv = "";
    var interval = setInterval(function () {
        var inv_new = JSON.stringify(bot.inventory.slots);
        if (inv !== inv_new) {
            inv = inv_new;
            socket.emit("inventory", bot.inventory.slots);
        }
        var entities = {
            mobs: [],
            players: [],
        };
        for (var k in bot.entities) {
            var v = bot.entities[k];
            if (v.type === "mob") {
                entities.mobs.push([v.position.x, v.position.y, v.position.z]);
            }
            if (v.type === "player") {
                entities.players.push([
                    v.username,
                    v.position.x,
                    v.position.y,
                    v.position.z,
                ]);
            }
        }
        socket.emit("entities", entities);
    }, 100);
    bot.once("spawn", function () {
        socket.on("fly", function (toggle) {
            if (toggle) {
                bot.creative.startFlying();
            } else {
                bot.creative.stopFlying();
            }
        });
        socket.on("blockPlace", function (pos, vec) {
            var block = bot.blockAt(new vec3(...pos));
            if (heldItem !== void 0 && heldItem !== null) {
                console.log(heldItem);
                bot.placeBlock(block, new vec3(...vec), function (r) {
                    console.log(r);
                });
            }
        });
        socket.on("invc", function (num) {
            var item = bot.inventory.slots[num + 36];
            if (item !== null && item !== void 0) {
                bot.equip(item, "hand");
            } else if (heldItem !== void 0) {
                bot.unequip("hand");
            }
        });
        socket.on("move", function (state, toggle) {
            if (state === "right") {
                state = "left";
            } else if (state === "left") {
                state = "right";
            }
            bot.setControlState(state, toggle);
        });
        socket.on("command", function (com) {
            bot.chat(com);
        });
        socket.on("rotate", function (data) {
            bot.look(...data);
        });
        socket.on("disconnect", function () {
            try {
                clearInterval(interval);
                console.log(`[\x1b[31m-\x1b[0m] ${query.nick}`);
                bot.end();
            } catch (error) {}
        });
        socket.on("dig", function (pos) {
            var block = bot.blockAt(vec3(pos[0], pos[1] - 16, pos[2]));
            if (block !== null) {
                var digTime = bot.digTime(block);
                if (bot.targetDigBlock !== null) {
                    console.log("Already digging...");
                    bot.stopDigging();
                }
                socket.emit("digTime", digTime, block);
                console.log("Start");
                bot.dig(block, false, function (xd) {
                    if (xd === void 0) {
                        return console.log("SUCCESS");
                    } else {
                        return console.log("FAIL");
                    }
                });
            }
        });
        socket.emit("stopDigging", function () {
            bot.stopDigging();
        });
    });
});
