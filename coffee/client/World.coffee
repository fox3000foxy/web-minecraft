
import pChunk from 'prismarine-chunk'
import vec3 from 'vec3'
import ndarray from "ndarray"

class World
	constructor:(noa)->
		_this=@
		@noa=noa
		@Chunk=pChunk "1.16.3"
		@chunkStorage={}
		@chunkNeedsUpdate={}
		@noa.world.on 'worldDataNeeded', (id, data, x, y, z)->
			noaChunk=_this.chunkStorage[id]
			for ix in [0..15]
				for iy in [0..15]
					for iz in [0..15]
						data.set ix,iy,iz,noaChunk.get ix,iy,iz
			_this.noa.world.setChunkData id, data
			return
		@noa.world.on "playerEnteredChunk",(ci,cj,ck)->
			console.log ci,cj,ck
			add = _this.noa.world.chunkAddDistance
			for i in [ci-add..ci+add]
				for j in [cj-add..cj+add]
					for k in [ck-add..ck+add]
						if not _this.noa.world._chunksKnown.includes(i, j, k)
							if _this.chunkStorage["#{i}|#{j}|#{k}|default"] isnt undefined
								_this.noa.world.manuallyLoadChunk i*16,j*16,k*16
			dist = _this.noa.world.chunkRemoveDistance
			_this.noa.world._chunksKnown.forEach (loc)->
				if _this.noa.world._chunksToRemove.includes(loc[0], loc[1], loc[2])
					return
				di = loc[0] - ci
				dj = loc[1] - cj
				dk = loc[2] - ck
				if dist <= Math.abs(di) or dist <= Math.abs(dj) or dist <= Math.abs(dk)
					_this.noa.world.manuallyUnloadChunk(loc[0] * 16, loc[1] * 16, loc[2] * 16)
				return
			return
		setInterval ()->
			if not _this.noa.world.playerChunkLoaded
				console.log "Updating Player Chunk!"
				pos = _this.noa.ents.getPosition(_this.noa.playerEntity)
				i = Math.ceil(pos[0] / 16)
				j = Math.ceil(pos[1] / 16)
				k = Math.ceil(pos[2] / 16)
				if _this.chunkStorage["#{i}|#{j}|#{k}|default"] isnt undefined
					_this.noa.world.manuallyLoadChunk i*16,j*16,k*16
			return
		,100
		return
	loadChunk:(chunk,x,z)->
		ch=@Chunk.fromJson chunk
		for y in [0..ch.sections.length-1]
			noaChunk=new ndarray new Uint16Array(16*16*16),[16, 16, 16]
			if ch.sections[y] isnt null
				for ix in [0..15]
					for iy in [0..15]
						for iz in [0..15]
							bid=ch.sections[y].getBlock vec3 ix,iy,iz
							if bid is 0
								noaChunk.set ix,iy,iz,0
							else
								noaChunk.set ix,iy,iz,1
			@chunkStorage["#{x}|#{y}|#{z}|default"]=noaChunk
			add = @noa.world.chunkAddDistance
			pos = @noa.ents.getPosition(@noa.playerEntity)
			ci = Math.ceil(pos[0] / 16)
			cj = Math.ceil(pos[1] / 16)
			ck = Math.ceil(pos[2] / 16)
			if x > ci - add && x < ci + add && y > cj - add && y < cj + add && z > ck - add && z < ck + add
				@noa.world.manuallyLoadChunk x*16,y*16,z*16
		return
export {World}
