
express=require 'express'
app=express()
http=require "http"
server=http.createServer(app)
io=require("socket.io") server,{cors:{origin:"*"}}

socketInfo={}
PORT=8081

server.listen PORT,()->
	console.log "Server is running on \x1b[34m*:#{PORT}\x1b[0m"

io.sockets.on "connection", (socket)->
	socketInfo[socket.id]={}
	socket.on "initClient",(nick)->
		console.log "[\x1b[32m+\x1b[0m] #{nick}"
		socketInfo[socket.id].nick=nick
		return
	socket.on "disconnect",()->
		console.log "[\x1b[31m-\x1b[0m] #{socketInfo[socket.id].nick}"
		delete socketInfo[socket.id]
		return
	return
