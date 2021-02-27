function selectItem(type) {
	select = new XMLHttpRequest();
	select.responseType = "json"
	select.open("get", "http://" + ip + ":8080/selectItem/" + type, true);
	select.send()
}
function dropItem(type) {
	window.event.preventDefault()
	select = new XMLHttpRequest();
	select.responseType = "json"
	select.open("get", "http://" + ip + ":8080/dropItem/" + type, true);
	select.send()
}
function invertItem(type) {
	window.event.preventDefault()
	select = new XMLHttpRequest();
	select.responseType = "json"
	select.open("get", "http://" + ip + ":8080/invertItem/" + type, true);
	select.send()
}
function equipItem(slot) {
	window.event.preventDefault()
	select = new XMLHttpRequest();
	select.responseType = "json"
	select.open("get", "http://" + ip + ":8080/equipItem/" + selectedItemType + "/" + slot, true);
	select.send()
}
function unequipItem(slot) {
	window.event.preventDefault()
	select = new XMLHttpRequest();
	select.responseType = "json"
	select.open("get", "http://" + ip + ":8080/unequipItem/" + slot, true);
	select.send()
}

function scrollItem(dir, newItem) {
	select = new XMLHttpRequest();
	select.responseType = "json"
	select.open("get", "http://" + ip + ":8080/scrollItem/" + dir + "/" + newItem, true);
	select.send()
}
