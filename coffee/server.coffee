
express=require 'express'
app=express()
http=require "http"
server=http.createServer(app)
io=require("socket.io") server,{cors:{origin:"*"}}

sf={}
socketInfo={}
PORT=8081

server.listen PORT,()->
	console.log "Server is running on \x1b[34m*:#{PORT}\x1b[0m"

io.sockets.on "connection", (socket)->
	console.log "[+] #{socket.id}"
	socket.on "disconnect",()->
		console.log "[-] #{socket.id}"
	return
