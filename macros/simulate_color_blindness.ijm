colorBlindessModes = newArray("Normal", "Protanopia (no red)", "Deuteranopia (no green)", "Tritanopia (no blue)", "Protanomaly (low red)", "Deuteranomaly (low green)", "Tritanomaly (low blue)", "Typical Monochromacy");

title = getTitle();

for(i=0;i<colorBlindessModes.length;i++){
	selectWindow(title);
	run("Duplicate...", "title=["+colorBlindessModes[i]+"]");
	run("Simulate Color Blindness", "mode=["+colorBlindessModes[i]+"]");
}
run("Tile");