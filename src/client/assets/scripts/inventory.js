selectedId = 0
ip = location.href.split("http://")[1].split(":")[0] || "localhost"
sI = new XMLHttpRequest();
sI.responseType = "json"
inventory = new XMLHttpRequest();
inventory.responseType = "json"
types = new XMLHttpRequest();
types.responseType = "json"
types.open("get", "http://" + ip + ":8080/types", true);
trueAcc = new XMLHttpRequest();
trueAcc.open("get", "http://" + ip + ":8080/trueAcc", true);
trueAcc.send()
ancientbuffer = ""
namePlayer = new XMLHttpRequest()
namePlayer.open("get", "http://" + ip + ":8080/name", true);
namePlayer.send()
ok = 0

function loaded() {
	setInterval(() => {
		inventory.open("get", "http://" + ip + ":8080/inventory", true);
		inventory.send();
		sI.open("get", "http://" + ip + ":8080/selectedItem", true);
		sI.send();
		setInterval(() => {
			if (inventory.response) {
				buffer = ""
				counter = 0
				equipement()
				offhand()
				slots()
				if (ancientbuffer != buffer) {
					ancientbuffer = buffer
					document.getElementById("inv").innerHTML = "<table><tr>" + buffer + "</tr></table>"
				}
				if (sI.response != null) {
					document.getElementById(selectedId).style.border = "3px solid gray"
					selectedId = sI.response + 27
					document.getElementById(selectedId).style.border = "3px solid white"
					selectedItemType = document.getElementById(selectedId).getAttribute('type')
				}
			}
		})
	}, 250)
	skinShow = setInterval(() => {
		src = trueAcc.response == "true" ? mcSkin() : tlSkin()
		if (namePlayer.response) {
			document.getElementById("skin").innerHTML = `<img class="skin" src="${src}">`
			renderMCSkins('skin', 2.3)
			clearInterval(skinShow)
		}
	})
}
