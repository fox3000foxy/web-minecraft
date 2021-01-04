
import TWEEN from "@tweenjs/tween.js"
import { Mesh } from '@babylonjs/core/Meshes/mesh'
import '@babylonjs/core/Meshes/Builders/boxBuilder'

class Player
	constructor:(noa)->
		_this=@
		@noa=noa
		@player=@noa.playerEntity
		@scene=@noa.rendering.getScene()
		dat = noa.entities.getPositionData @player
		w = dat.width
		h = dat.height
		mesh = Mesh.CreateBox 'player-mesh', 0, @scene
		mesh.scaling.x = w
		mesh.scaling.z = w
		mesh.scaling.y = h
		@noa.entities.addComponent @player, @noa.entities.names.mesh,
			mesh: mesh
			offset: [0, h / 2, 0]
		@body=@noa.physics.bodies[0]
		setInterval ()->
			_this.resetForces()
			return
		# @noa.inputs.down.on 'fire',()->
		# 	if _this.noa.targetedBlock
		# 		_this.noa.setBlock 0, _this.noa.targetedBlock.position
		# 	return
		# @noa.inputs.down.on 'alt-fire',()->
		# 	if _this.noa.targetedBlock
		# 		_this.noa.addBlock grassID, _this.noa.targetedBlock.adjacent
		# 	return
		# @noa.inputs.bind 'alt-fire', 'E'
		@noa.on 'tick',(dt)->
			scroll=_this.noa.inputs.state.scrolly
			if scroll isnt 0
				_this.noa.camera.zoomDistance += if scroll>0 then 1 else -1
				if _this.noa.camera.zoomDistance < 0
					_this.noa.camera.zoomDistance=0
				if _this.noa.camera.zoomDistance > 10
					_this.noa.camera.zoomDistance=10
			return
		return
	updatePosition:(x,y,z)->
		@noa.entities.setPosition @player,[-x,y,z]
		return
	resetForces:()->
		@body.velocity[0]=0
		@body.velocity[1]=0
		@body.velocity[2]=0
		@body._forces[0]=0
		@body._forces[1]=0
		@body._forces[2]=0
		@body._impulses[0]=0
		@body._impulses[1]=0
		@body._impulses[2]=0
		@body.gravityMultiplier=0
		return
export {Player}
