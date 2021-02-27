function offhand() {
	i = inventory.response.slots.length - 1
	if (inventory.response.slots[i] != null && inventory.response.slots[i].slot != 5) {
		texture = inventory.response.slots[i].name
		texture = texture == "grass_block" ? "grass_block_side" : texture
		count = inventory.response.slots[i].count == 1 ? "<span style='color:lightgray'>.</span>" : inventory.response.slots[i].count
		type = inventory.response.slots[i].type
		onclickattr = 'onclick="invertItem(' + inventory.response.slots[i].type + ')"'
		title = inventory.response.slots[i].displayName
	}
	else {
		texture = "air"
		count = ""
		onclickattr = ''
		type = 0
		title = ""
	}

	buffer += `<td id="${counter}" type="${type}"><div class="item"><img class="item" title="${title}" src="http://${ip}:8080/assets/minecraft/textures/item/${texture}.png" onerror='this.onerror = null; this.src="http://${ip}:8080/assets/minecraft/textures/block/${texture}.png"' ${onclickattr}><div class="counter">${count}</div></div></td>`

	counter = 0
}
