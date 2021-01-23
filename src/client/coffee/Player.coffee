
import TWEEN from "@tweenjs/tween.js"
import { Mesh } from '@babylonjs/core/Meshes/mesh'
import '@babylonjs/core/Meshes/Builders/boxBuilder'

class Player
	constructor:(noa)->
		_this=@
		@noa=noa
		@player=@noa.playerEntity
		@scene=@noa.rendering.getScene()
		@scene.cameras[0].fov=1
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
		console.log @body
		return
	tick:()->
		@resetForces()
		TWEEN.update()
		@resetForces()
		return
	updatePosition:(x,y,z)->
		_this=@
		pos=@noa.entities.getPosition @player
		data_from={x:pos[0],y:pos[1],z:pos[2]}
		data_to={x:-x,y,z}
		# @noa.entities.setPosition @player,[data_to.x,data_to.y,data_to.z]
		tw=new TWEEN.Tween(data_from)
			.to data_to,50
			.easing TWEEN.Easing.Quadratic.Out
			.onUpdate ()->
				# console.log [data_from.x,data_from.y,data_from.z]
				_this.noa.entities.setPosition _this.player,[data_from.x,data_from.y,data_from.z]
				return
			.start()
		return
	updateFov:(type,toggle)->
		if type is "sprint"
			if toggle
				new TWEEN.Tween(@scene.cameras[0])
					.to {fov:1.2},200
					.easing TWEEN.Easing.Quadratic.Out
					.start()
			else
				new TWEEN.Tween(@scene.cameras[0])
					.to {fov:1},200
					.easing TWEEN.Easing.Quadratic.Out
					.start()
	resetForces:()->
		@body.airDrag=0
		@body.fluidDrag=0
		@body.mass=0
		@body.friction=0
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
