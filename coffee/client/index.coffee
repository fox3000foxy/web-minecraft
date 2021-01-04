
import Engine from 'noa-engine'
import {io} from 'socket.io-client'
import {World} from "./World"
import {Player} from "./Player"
import * as BABYLON from '@babylonjs/core/Legacy/legacy'
import $ from "jquery"

socket=io ":8081"

noa=new Engine
	debug: true
	showFPS: true
	chunkSize: 16
	playerStart: [0.5, 100, 0.5]
	chunkAddDistance: 6
	chunkRemoveDistance: 6
	useAO: true
	manuallyControlChunkLoading: true

console.log noa

world=new World noa
player=new Player noa

kc=
	87:"forward"
	65:"right"
	83:"back"
	68:"left"
	32:"jump"
	16:"sneak"
	82:"sprint"

$(document).keydown (z)->
	if kc[z.keyCode] isnt undefined
		socket.emit "move",kc[z.keyCode],true
	return
$(document).keyup (z)->
	if kc[z.keyCode] isnt undefined
		socket.emit "move",kc[z.keyCode],false
	return

socket.on "connect",()->
	console.log "connected"
	socket.emit "initClient","noaPlayerX"
	socket.on "mapChunk",(chunk,x,z)->
		world.loadChunk chunk,x,z
		return
	socket.on "move",(x,y,z)->
		player.updatePosition x,y,z
		return
	socket.on "disconnect",()->
		console.log "disconnected"
		return
	return

scene = noa.rendering.getScene()
scene.fogMode=BABYLON.Scene.FOGMODE_LINEAR
scene.fogStart = 4*16
scene.fogEnd = 5*16
scene.fogColor = new BABYLON.Color3 204/255, 232/255, 255/255
