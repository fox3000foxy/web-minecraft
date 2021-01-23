
import Engine from 'noa-engine'
import { Scene } from "@babylonjs/core/scene"
import { Color3 } from '@babylonjs/core'
import $ from "jquery"

import {io} from 'socket.io-client'
import {World} from "./World.coffee"
import {Player} from "./Player.coffee"

console.log document

socket=io()

noa=new Engine
	debug: true
	showFPS: true
	chunkSize: 16
	chunkAddDistance: 5
	chunkRemoveDistance: 5
	useAO: true
	manuallyControlChunkLoading: true
	texturePath: 'textures/'
	tickRate:60

console.log noa

world=new World noa
player=new Player noa

noa.rendering.tick=()->
	# console.log "tick"
	pitch=noa.camera.pitch
	yaw=noa.camera.heading
	socket.emit "look",-yaw+Math.PI,-pitch
	player.tick()
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
scene.fogMode=Scene.FOGMODE_LINEAR
scene.fogStart = (noa.world.chunkAddDistance-2)*16
scene.fogEnd = (noa.world.chunkAddDistance-1)*16
scene.fogColor = new Color3 204/255, 232/255, 255/255
