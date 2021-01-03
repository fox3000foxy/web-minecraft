
import Engine from 'noa-engine'
import { io } from 'socket.io-client'
import { Mesh } from '@babylonjs/core/Meshes/mesh'
import '@babylonjs/core/Meshes/Builders/boxBuilder'
import {World} from "./World"

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

world=new World noa

socket.on "connect",()->
	console.log "connected"
	socket.emit "initClient","noaPlayer"
	socket.on "mapChunk",(chunk,x,z)->
		world.loadChunk chunk,x,z
		return
	socket.on "disconnect",()->
		console.log "disconnected"
		return
	return

textureURL = null
brownish = [0.45, 0.36, 0.22]
greenish = [0.1, 0.8, 0.2]
noa.registry.registerMaterial 'dirt', brownish, textureURL
noa.registry.registerMaterial 'grass', greenish, textureURL

dirtID = noa.registry.registerBlock 1, { material: 'dirt' }
grassID = noa.registry.registerBlock 2, { material: 'grass' }

player = noa.playerEntity
dat = noa.entities.getPositionData player
w = dat.width
h = dat.height

scene = noa.rendering.getScene()
mesh = Mesh.CreateBox 'player-mesh', 1, scene
mesh.scaling.x = w
mesh.scaling.z = w
mesh.scaling.y = h

noa.entities.addComponent player, noa.entities.names.mesh,
    mesh: mesh
    offset: [0, h / 2, 0]

noa.inputs.down.on 'fire',()->
	if noa.targetedBlock
		noa.setBlock 0, noa.targetedBlock.position
	return

noa.inputs.down.on 'alt-fire',()->
	if noa.targetedBlock
		noa.addBlock grassID, noa.targetedBlock.adjacent
	return

noa.inputs.bind 'alt-fire', 'E'

noa.on 'tick',(dt)->
	scroll=noa.inputs.state.scrolly
	if scroll isnt 0
		noa.camera.zoomDistance += if scroll>0 then 1 else -1
		if noa.camera.zoomDistance < 0
			noa.camera.zoomDistance=0
		if noa.camera.zoomDistance > 10
			noa.camera.zoomDistance=10
	return
