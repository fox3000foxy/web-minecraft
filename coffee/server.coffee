
express=require 'express'
app=express()
http=require "http"
server=http.createServer(app)
io=require("socket.io") server,{cors:{origin:"*"}}
mineflayer=require "mineflayer"
Chunk=require("prismarine-chunk")("1.16.3")
si={}
PORT=8081

server.listen PORT,()->
	console.log "Server is running on \x1b[34m*:#{PORT}\x1b[0m"

io.sockets.on "connection", (socket)->
	si[socket.id]={}
	socket.on "initClient",(nick)->
		console.log "[\x1b[32m+\x1b[0m] #{nick}"
		si[socket.id].nick=nick
		si[socket.id].bot=mineflayer.createBot {
			host: "localhost"
			port: 25565
			username: nick
			version:"1.16.3"
		}
		si[socket.id].bot._client.on "map_chunk",(packet)->
			cell=new Chunk()
			cell.load packet.chunkData,packet.bitMap
			socket.emit "mapChunk",cell.toJson()
			return
		return
	socket.on "disconnect",()->
		console.log "[\x1b[31m-\x1b[0m] #{si[socket.id].nick}"
		si[socket.id].bot.end()
		delete si[socket.id]
		return
	return
