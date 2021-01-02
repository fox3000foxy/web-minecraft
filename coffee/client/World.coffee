
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
			if _this.chunkStorage[id] isnt undefined
				if _this.chunkNeedsUpdate[id]
					_this.noa.world.setChunkData id, _this.chunkStorage[id]
					_this.chunkNeedsUpdate[id]=false
			return
	loadChunk:(chunk,x,z)->
		ch=@Chunk.fromJson chunk
		for y in [0..ch.sections.length-1]
			noaChunk=new ndarray new Uint16Array(16*16*16),[16, 16, 16]
			if ch.sections[y] isnt null
				# console.log x,i,z
				for ix in [0..15]
					for iy in [0..15]
						for iz in [0..15]
							bid=ch.sections[y].getBlock vec3 ix,iy,iz
							if bid is 0
								noaChunk.set ix,iy,iz,0
							else
								noaChunk.set ix,iy,iz,1
			@chunkStorage["#{x}|#{y}|#{z}|default"]=noaChunk
			@chunkNeedsUpdate["#{x}|#{y}|#{z}|default"]=true
			@noa.world.manuallyLoadChunk x*16,y*16,z*16
		return
export {World}
