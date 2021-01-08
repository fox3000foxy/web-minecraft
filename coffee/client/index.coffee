
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
	chunkAddDistance: 4
	chunkRemoveDistance: 4
	useAO: true
	manuallyControlChunkLoading: true
	texturePath: 'textures/'

console.log noa.camera

animate=()->
	requestAnimationFrame animate
	dir=noa.camera.getDirection()
	pitch=noa.camera.pitch
	yaw=noa.camera.heading
	socket.emit "look",-yaw+Math.PI,-pitch
	return
animate()

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
		player.updateFov kc[z.keyCode],true
	return
$(document).keyup (z)->
	if kc[z.keyCode] isnt undefined
		socket.emit "move",kc[z.keyCode],false
		player.updateFov kc[z.keyCode],false
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
scene.fogStart = 2*16
scene.fogEnd = 3*16
scene.fogColor = new BABYLON.Color3 204/255, 232/255, 255/255
