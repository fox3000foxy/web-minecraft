
express=require 'express'
app=express()
http=require "http"
server=http.createServer(app)
io=require("socket.io") server,{cors:{origin:"*"}}
mineflayer=require "mineflayer"

socketInfo={}
PORT=8081

server.listen PORT,()->
	console.log "Server is running on \x1b[34m*:#{PORT}\x1b[0m"

io.sockets.on "connection", (socket)->
	socketInfo[socket.id]={}
	socket.on "initClient",(nick)->
		console.log "[\x1b[32m+\x1b[0m] #{nick}"
		socketInfo[socket.id].nick=nick
		socketInfo[socket.id].bot=mineflayer.createBot {
			host: "localhost"
			port: 25565
			username: nick
		}
		return
	socket.on "disconnect",()->
		console.log "[\x1b[31m-\x1b[0m] #{socketInfo[socket.id].nick}"
		socketInfo[socket.id].bot.end()
		delete socketInfo[socket.id]
		return
	return
