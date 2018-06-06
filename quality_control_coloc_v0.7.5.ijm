print("\\Clear");
run("Set Measurements...", "area mean standard modal min centroid center integrated median limit display redirect=None decimal=4");
roiManager("reset");
run("Clear Results");

channel_array = newArray("DAPI", "GFP", "RFP", "Cy5", "CFP", "YFP", "mCherry", "None");
NA = newArray("0.5", "0.7", "0.75", "0.85", "0.95", "1.15", "1.2", "1.25", "1.3", "1.4", "1.42", "1.44", "1.45", "1.49");

//prompt to open a new image and on how to open it
if (nImages == 0) {
	Dialog.create("");
	Dialog.addMessage("There are no images open.");
	Dialog.addRadioButtonGroup("Open new image?", newArray("Yes", "No"), 1, 2, "Yes");
	Dialog.addRadioButtonGroup("Use Bio-Formats to open image?", newArray("Yes", "No"), 1, 2, "Yes");
	Dialog.show;
	q = Dialog.getRadioButton();
	loci = Dialog.getRadioButton();
	//q = getBoolean("Open image?");
	if (q == "Yes") {
		if(loci == "Yes") {
			print("Opening new image with Bio-formats");
			run("Bio-Formats Importer");
		} else {
			open();
			print("Opening a new image");
		}
	};
	dir = File.directory;
	//print("dir from file.directory");
} else if(nImages == 1) {
	dir = getInfo("image.directory");
	//print("dir from getInfo");
}

filename = getTitle();
title = File.nameWithoutExtension();
selectWindow(filename);
//dir = File.directory;
print("Image Dir: "+dir);
print("File: "+filename);
print("Title: "+title);

Stack.getDimensions(width, height, channels, slices, frames);
print("Number of channels: "+channels);

//window to get define details and parameters
Dialog.create("Info setup.");
Dialog.addMessage("Choose existing channels and their order");
Dialog.addMessage("Image name: "+title+"");
Dialog.addMessage("Image Directory: "+dir);
Dialog.addMessage("Current image dimensions: \nWidth: "+width+" \nHeight: "+height+" \nChannels: "+channels+" \nZ Slices:"+slices+" \nT frames: "+frames);
Dialog.addChoice("Channel 1", channel_array, channel_array[0]);
Dialog.addChoice("Channel 2", channel_array, channel_array[1]);
Dialog.addChoice("Channel 3", channel_array, channel_array[2]);
Dialog.addChoice("Channel 4", channel_array, channel_array[3]);
Dialog.addRadioButtonGroup("Microscope type", newArray("WideField", "Confocal"), 1, 2, "WideField");
Dialog.addChoice("Objective NA", NA);
Dialog.addRadioButtonGroup("Images in same folder?", newArray("Yes", "No"), 1, 2, "Yes");
Dialog.addRadioButtonGroup("Show final concatenated arrays?", newArray("Yes", "No"), 1, 2, "No");
Dialog.show;
chan1 = Dialog.getChoice;
chan2 = Dialog.getChoice;
chan3 = Dialog.getChoice;
chan4 = Dialog.getChoice;
type = Dialog.getRadioButton;
num_ap = Dialog.getChoice;
folders = Dialog.getRadioButton;
show_array = Dialog.getRadioButton;

print("Channel 1: "+chan1);
print("Channel 2: "+chan2);
print("Channel 3: "+chan3);
print("Channel 4: "+chan4);
print("Type: "+type);

run("Properties...");
getVoxelSize(pixelWidth, pixelHeight, depth, unit);

pixelSize = 0;
if (pixelWidth == pixelHeight) {
	pixelSize = pixelWidth;
}else {
	print("pixel Width and Height is not equal");
};
print("pixelSize: "+pixelSize);

wavelength1 = lambda(chan1);
wavelength2 = lambda(chan2);
wavelength3 = lambda(chan3);
wavelength4 = lambda(chan4);

print("wavelength1: "+wavelength1);
print("wavelength2: "+wavelength2);
print("wavelength3: "+wavelength3);
print("wavelength4: "+wavelength4);

save_dir = "";
if (folders == "No") {
	Parent = File.getParent(dir);
	File.makeDirectory(Parent+"\\Co-loc reports\\");
	File.makeDirectory(Parent+"\\Co-loc reports\\"+title+"\\");
	save_dir = Parent+"\\Co-loc reports\\"+title+"\\";
	print("Saving to: "+save_dir);
} else {
	File.makeDirectory(dir+"\\Co-loc reports\\");
	File.makeDirectory(dir+"\\Co-loc reports\\"+title+"\\");
	save_dir = dir+"\\Co-loc reports\\"+title+"\\";
	print("Saving to: "+save_dir);
};

if (chan1 == chan2 || chan1 == chan3 || chan1 == chan4 || chan2 == chan3 || chan2 == chan4 || chan3 == chan4) {
	exit("You cannot have 2 equal channels!");
};

if (channels > 3) {
	Stack.setChannel(1);
	print("setting channel 1");
} else {
	Stack.setChannel(0);
	print("setting channel 0");
};

find_max();

setAutoThreshold("Otsu dark");
roiManager("reset");
pontos = roiManager("count");
analisarParticulas();
controlo();

setBatchMode(true);
pontos = roiManager("count");
for (i = 0; i < pontos ; i++) {
	selectWindow(filename);
	roiManager("Show All");
	roiManager("Select", i);
	roiManager("Rename", "bead"+(i));
	run("Enlarge...", "enlarge=5 pixel");
	run("Duplicate...", "title=[bead stack "+i+"] duplicate");
	//selectWindow(title);
	table_name = "[Bead coord list bead"+i+"]";
	table_name_2 = "Bead coord list bead"+i;
	run("New... ", "name="+table_name+" type=Table");
	print(table_name, "channel coord; x ; y; z;");
	selectWindow("bead stack "+i);
	
	run("Split Channels");
	for (j=1; j<=channels; j++) {
		selectWindow("C"+j+"-bead stack "+i);
		if (j == 1) {
			newtitle = chan1;
		} else if (j == 2) {
			newtitle = chan2;
		} else if (j == 3) {
			newtitle = chan3;
		} else if (j == 4) {
			newtitle = chan4;
		} else {
			newtitle = filename;
		};
		rename(newtitle);
	};

	chan_val_1 = newArray();
	chan_val_2 = newArray();
	chan_val_3 = newArray();
	if (chan4 != "None") {
		chan_val_4 = newArray();
	};
	
	selectWindow(chan1);
	run("Select None");
	run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	//find_max();
	run("Z Project...", "type=[Max Intensity]");
	setAutoThreshold("Otsu dark");
	run("Analyze Particles...", "size=1-1500 pixel display clear slice");
	x_1 = getResult("XM");
	y_1 = getResult("YM");
	close("MAX_"+chan1);

	selectWindow(chan1);
	run("Reslice [/]...", "output="+pixelSize+" start=Left rotate avoid");
	run("Z Project...", "type=[Max Intensity]");
	setAutoThreshold("Otsu dark");
	run("Analyze Particles...", "size=1-1500 pixel display clear slice");
	z_1 = getResult("XM");
	close("MAX_"+chan1);
	
	print(table_name, chan1+"; "+x_1+" ; "+y_1+" ; "+z_1);
	chan_val_1 = Array.concat(chan_val_1, x_1);
	chan_val_1 = Array.concat(chan_val_1, y_1);
	chan_val_1 = Array.concat(chan_val_1, z_1);
	//Array.show(chan_val_1);

	selectWindow(chan2);
	run("Select None");
	run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	//find_max();
	run("Z Project...", "type=[Max Intensity]");
	setAutoThreshold("Otsu dark");
	run("Analyze Particles...", "size=1-1500 pixel display clear slice");
	x_2 = getResult("XM");
	y_2 = getResult("YM");
	close("MAX_"+chan2);

	selectWindow(chan2);
	run("Reslice [/]...", "output="+pixelSize+" start=Left rotate avoid");
	run("Z Project...", "type=[Max Intensity]");
	setAutoThreshold("Otsu dark");
	run("Analyze Particles...", "size=1-1500 pixel display clear slice");
	z_2 = getResult("XM");
	close("MAX_"+chan2);
	
	print(table_name, chan2+"; "+x_2+" ; "+y_2+" ; "+z_2);
	chan_val_2 = Array.concat(chan_val_2, x_2);
	chan_val_2 = Array.concat(chan_val_2, y_2);
	chan_val_2 = Array.concat(chan_val_2, z_2);

	selectWindow(chan3);
	run("Select None");
	run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
	//find_max();
	run("Z Project...", "type=[Max Intensity]");
	setAutoThreshold("Otsu dark");
	run("Analyze Particles...", "size=1-1500 pixel display clear slice");
	x_3 = getResult("XM");
	y_3 = getResult("YM");
	close("MAX_"+chan3);

	selectWindow(chan3);
	run("Reslice [/]...", "output="+pixelSize+" start=Left rotate avoid");
	run("Z Project...", "type=[Max Intensity]");
	setAutoThreshold("Otsu dark");
	run("Analyze Particles...", "size=1-1500 pixel display clear slice");
	z_3 = getResult("XM");
	close("MAX_"+chan3);
	
	print(table_name, chan3+"; "+x_3+" ; "+y_3+" ; "+z_3);
	chan_val_3 = Array.concat(chan_val_3, x_3);
	chan_val_3 = Array.concat(chan_val_3, y_3);
	chan_val_3 = Array.concat(chan_val_3, z_3);

	if (chan4 != "None") {
		selectWindow(chan4);
		run("Select None");
		run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
		//find_max();
		run("Z Project...", "type=[Max Intensity]");
		setAutoThreshold("Otsu dark");
		run("Analyze Particles...", "size=1-1500 pixel display clear slice");
		x_4 = getResult("XM");
		y_4 = getResult("YM");
		close("MAX_"+chan4);
	
		selectWindow(chan4);
		run("Reslice [/]...", "output="+pixelSize+" start=Left rotate avoid");
		run("Z Project...", "type=[Max Intensity]");
		setAutoThreshold("Otsu dark");
		run("Analyze Particles...", "size=1-1500 pixel display clear slice");
		z_4 = getResult("XM");
		close("MAX_"+chan4);
		print(table_name, chan4+"; "+x_4+" ; "+y_4+" ; "+z_4);
		chan_val_4 = Array.concat(chan_val_4, x_4);
		chan_val_4 = Array.concat(chan_val_4, y_4);
		chan_val_4 = Array.concat(chan_val_4, z_4);
	};
	

	print(table_name, "raw dist px; x; y; z");
	print(table_name, chan1+"vs"+chan2+"; "+chan_val_1[0]-chan_val_2[0]+"; "+chan_val_1[1]-chan_val_2[1]+"; "+chan_val_1[2]-chan_val_2[2]);
	print(table_name, chan1+"vs"+chan3+"; "+chan_val_1[0]-chan_val_3[0]+"; "+chan_val_1[1]-chan_val_3[1]+"; "+chan_val_1[2]-chan_val_3[2]);
	print(table_name, chan2+"vs"+chan3+"; "+chan_val_2[0]-chan_val_3[0]+"; "+chan_val_2[1]-chan_val_3[1]+"; "+chan_val_2[2]-chan_val_3[2]);
	if (chan4 != "None") {
		print(table_name, chan1+"vs"+chan4+"; "+chan_val_1[0]-chan_val_4[0]+"; "+chan_val_1[1]-chan_val_4[1]+"; "+chan_val_1[2]-chan_val_4[2]);
		print(table_name, chan2+"vs"+chan4+"; "+chan_val_2[0]-chan_val_4[0]+"; "+chan_val_2[1]-chan_val_4[1]+"; "+chan_val_2[2]-chan_val_4[2]);
		print(table_name, chan3+"vs"+chan4+"; "+chan_val_3[0]-chan_val_4[0]+"; "+chan_val_3[1]-chan_val_4[1]+"; "+chan_val_3[2]-chan_val_4[2]);
	};

	//euclidian distance 2d
	print(table_name, "euclidian 2d ; px; um");
	d1 = distance_2d(chan_val_1, chan_val_2);
	print(table_name, chan1+" vs "+chan2+"; "+d1+" ; "+d1*pixelSize);
	d2 = distance_2d(chan_val_1, chan_val_3);
	print(table_name, chan1+" vs "+chan3+"; "+d2+" ; "+d2*pixelSize);
	d4 = distance_2d(chan_val_2, chan_val_3);
	print(table_name, chan2+" vs "+chan3+"; "+d4+" ; "+d4*pixelSize);
	if (chan4 != "None") {
		d3 = distance_2d(chan_val_1, chan_val_4);
		print(table_name, chan1+" vs "+chan4+"; "+d3+" ; "+d3*pixelSize);
		d5 = distance_2d(chan_val_2, chan_val_4);
		print(table_name, chan2+" vs "+chan4+"; "+d5+" ; "+d5*pixelSize);
		d6 = distance_2d(chan_val_3, chan_val_4);
		print(table_name, chan3+" vs "+chan4+"; "+d6+" ; "+d6*pixelSize);
	};
	
	//euclidian distance 3d
	print(table_name, "euclidian 3d ; px; um");
	d1 = distance_3d(chan_val_1, chan_val_2);
	print(table_name, chan1+" vs "+chan2+"; "+d1+" ; "+d1*pixelSize);
	d2 = distance_3d(chan_val_1, chan_val_3);
	print(table_name, chan1+" vs "+chan3+"; "+d2+" ; "+d2*pixelSize);
	d4 = distance_3d(chan_val_2, chan_val_3);
	print(table_name, chan2+" vs "+chan3+"; "+d4+" ; "+d4*pixelSize);
	if (chan4 != "None") {
		d3 = distance_3d(chan_val_1, chan_val_4);
		print(table_name, chan1+" vs "+chan4+"; "+d3+" ; "+d3*pixelSize);
		d5 = distance_3d(chan_val_2, chan_val_4);
		print(table_name, chan2+" vs "+chan4+"; "+d5+" ; "+d5*pixelSize);
		d6 = distance_3d(chan_val_3, chan_val_4);
		print(table_name, chan3+" vs "+chan4+"; "+d6+" ; "+d6*pixelSize);
	};
	
	updateResults();
	selectWindow(table_name_2);

	if (File.exists(save_dir+"\\"+table_name_2+".csv") == true) {
		saveAs("Results", save_dir+"\\"+table_name_2+"_2.csv");
	} else if (File.exists(save_dir+"\\"+table_name_2+"_2.csv") == true) {
		saveAs("Results", save_dir+"\\"+table_name_2+"_3.csv");
	} else {
		saveAs("Results", save_dir+"\\"+table_name_2+".csv");
	};


	close(chan1);
	close(chan2);
	close(chan3);
	if (chan4 != "None") {
		close(chan4);
	};
	print(table_name, "\\Close");
};
setBatchMode(false);
list = getFileList(save_dir);
//print(list.length);


/////////////////////////////////////////////////////////////////////
//////////////Retrieve values from calculated differences////////////
//////////////uses fetch function////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//print("\nDAPI vs GFP");
print("Summary and Concatenated values");
print("\n "+chan1+" vs "+chan2);
//get x values
x_array_1 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	x_value = parseFloat(fetch(file, chan1+"vs"+chan2, "x"));
	x_array_1 = Array.concat(x_array_1, x_value);
};

if (show_array == "Yes") {
	Array.show(x_array_1);
};
Array.getStatistics(x_array_1, min, max, mean, stdDev);
print("Mean x: "+mean);
print("stdDev x: "+stdDev);

//get y values
y_array_1 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	y_value = parseFloat(fetch(file, chan1+"vs"+chan2, "y"));
	y_array_1 = Array.concat(y_array_1, y_value);
};

if (show_array == "Yes") {
	Array.show(y_array_1);
};

Array.getStatistics(y_array_1, min, max, mean, stdDev);
print("Mean y: "+mean);
print("stdDev y: "+stdDev);

//get z values
z_array_1 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	z_value = parseFloat(fetch(file, chan1+"vs"+chan2, "z"));
	z_array_1 = Array.concat(z_array_1, z_value);
};

if (show_array == "Yes") {
	Array.show(z_array_1);
};

Array.getStatistics(z_array_1, min, max, mean, stdDev);
print("Mean z: "+mean);
print("stdDev z: "+stdDev);

//////////////////////////////DAPI vs RFP//////////////////////////
//print("\nDAPI vs RFP");
print("\n "+chan1+" vs "+chan3);
//get x values
x_array_2 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	x_value = parseFloat(fetch(file, chan1+"vs"+chan3, "x"));
	x_array_2 = Array.concat(x_array_2, x_value);
};

if (show_array == "Yes") {
	Array.show(x_array_2);
};

Array.getStatistics(x_array_2, min, max, mean, stdDev);
print("Mean x: "+mean);
print("stdDev x: "+stdDev);

//get y values
y_array_2 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	y_value = parseFloat(fetch(file, chan1+"vs"+chan3, "y"));
	y_array_2 = Array.concat(y_array_2, y_value);
};

if (show_array == "Yes") {
	Array.show(y_array_2);
};

Array.getStatistics(y_array_2, min, max, mean, stdDev);
print("Mean y: "+mean);
print("stdDev y: "+stdDev);

//get z values
z_array_2 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	z_value = parseFloat(fetch(file, chan1+"vs"+chan3, "z"));
	z_array_2 = Array.concat(z_array_2, z_value);
};

if (show_array == "Yes") {
	Array.show(z_array_2);
};

Array.getStatistics(z_array_2, min, max, mean, stdDev);
print("Mean z: "+mean);
print("stdDev z: "+stdDev);

/////////////////////////DAPI vs Cy5//////////////////////////
//print("\nDAPI vs Cy5");
if (chan4 != "None") {
	print("\n "+chan1+" vs "+chan4);
	//get x values
	x_array_3 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		x_value = parseFloat(fetch(file, chan1+"vs"+chan4, "x"));
		x_array_3 = Array.concat(x_array_3, x_value);
	};
	
	if (show_array == "Yes") {
		Array.show(x_array_3);
	};
	
	Array.getStatistics(x_array_3, min, max, mean, stdDev);
	print("Mean x: "+mean);
	print("stdDev x: "+stdDev);
	
	//get y values
	y_array_3 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		y_value = parseFloat(fetch(file, chan1+"vs"+chan4, "y"));
		y_array_3 = Array.concat(y_array_3, y_value);
	};
	
	if (show_array == "Yes") {
		Array.show(y_array_3);
	};
	
	Array.getStatistics(y_array_3, min, max, mean, stdDev);
	print("Mean y: "+mean);
	print("stdDev y: "+stdDev);
	
	//get z values
	z_array_3 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		z_value = parseFloat(fetch(file, chan1+"vs"+chan4, "z"));
		z_array_3 = Array.concat(z_array_3, z_value);
	};
	
	if (show_array == "Yes") {
		Array.show(z_array_3);
	};
	
	Array.getStatistics(z_array_3, min, max, mean, stdDev);
	print("Mean z: "+mean);
	print("stdDev z: "+stdDev);
};


///////////////////////GFP vs RFP//////////////////////////
//print("\nGFP vs RFP");
print("\n "+chan2+" vs "+chan3);
//get x values
x_array_4 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	x_value = parseFloat(fetch(file, chan2+"vs"+chan3, "x"));
	x_array_4 = Array.concat(x_array_4, x_value);
};

if (show_array == "Yes") {
	Array.show(x_array_4);
};

Array.getStatistics(x_array_4, min, max, mean, stdDev);
print("Mean x: "+mean);
print("stdDev x: "+stdDev);

//get y values
y_array_4 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	y_value = parseFloat(fetch(file, chan2+"vs"+chan3, "y"));
	y_array_4 = Array.concat(y_array_4, y_value);
};

if (show_array == "Yes") {
	Array.show(y_array_4);
};

Array.getStatistics(y_array_4, min, max, mean, stdDev);
print("Mean y: "+mean);
print("stdDev y: "+stdDev);

//get z values
z_array_4 = newArray();
for (i=0;i<list.length;i++) {
	file = File.openAsString(save_dir+"\\"+list[i]);
	z_value = parseFloat(fetch(file, chan2+"vs"+chan3, "z"));
	z_array_4 = Array.concat(z_array_4, z_value);
};

if (show_array == "Yes") {
	Array.show(z_array_4);
};

Array.getStatistics(z_array_4, min, max, mean, stdDev);
print("Mean z: "+mean);
print("stdDev z: "+stdDev);

//////////////////////////GFP vs Cy5////////////////////
//print("\nGFP vs Cy5");
if (chan4 != "None") {
	print("\n "+chan2+"vs"+chan4);
	//get x values
	x_array_5 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		x_value = parseFloat(fetch(file, chan2+"vs"+chan4, "x"));
		x_array_5 = Array.concat(x_array_5, x_value);
	};
	
	if (show_array == "Yes") {
		Array.show(x_array_5);
	};
	
	Array.getStatistics(x_array_5, min, max, mean, stdDev);
	print("Mean x: "+mean);
	print("stdDev x: "+stdDev);
	
	//get y values
	y_array_5 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		y_value = parseFloat(fetch(file, chan2+"vs"+chan4, "y"));
		y_array_5 = Array.concat(y_array_5, y_value);
	};
	
	if (show_array == "Yes") {
		Array.show(y_array_5);
	};
	
	Array.getStatistics(y_array_5, min, max, mean, stdDev);
	print("Mean y: "+mean);
	print("stdDev y: "+stdDev);
	
	//get z values
	z_array_5 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		z_value = parseFloat(fetch(file, chan2+"vs"+chan4, "z"));
		z_array_5 = Array.concat(z_array_5, z_value);
	};
	
	if (show_array == "Yes") {
		Array.show(z_array_5);
	};
	
	Array.getStatistics(z_array_5, min, max, mean, stdDev);
	print("Mean z: "+mean);
	print("stdDev z: "+stdDev);
}

////////////////////////RFP vs Cy5//////////////////////////
//print("\nRFP vs Cy5");
if (chan4 != "None") {
	print("\n "+chan3+" vs "+chan4);
	//get x values
	x_array_7 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		x_value = parseFloat(fetch(file, chan3+"vs"+chan4, "x"));
		x_array_7 = Array.concat(x_array_7, x_value);
	};
	
	if (show_array == "Yes") {
		Array.show(x_array_7);
	};
	
	Array.getStatistics(x_array_7, min, max, mean, stdDev);
	print("Mean x: "+mean);
	print("stdDev x: "+stdDev);
	
	//get y values
	y_array_7 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		y_value = parseFloat(fetch(file, chan3+"vs"+chan4, "y"));
		y_array_7 = Array.concat(y_array_7, y_value);
	};
	
	if (show_array == "Yes") {
		Array.show(y_array_7);
	};
	
	Array.getStatistics(y_array_7, min, max, mean, stdDev);
	print("Mean y: "+mean);
	print("stdDev y: "+stdDev);
	
	//get z values
	z_array_7 = newArray();
	for (i=0;i<list.length;i++) {
		file = File.openAsString(save_dir+"\\"+list[i]);
		z_value = parseFloat(fetch(file, chan3+"vs"+chan4, "z"));
		z_array_7 = Array.concat(z_array_7, z_value);
	};
	
	if (show_array == "Yes") {
		Array.show(z_array_7);
	};
	
	Array.getStatistics(z_array_7, min, max, mean, stdDev);
	print("Mean z: "+mean);
	print("stdDev z: "+stdDev);
};

run("Close All");
print("Macro Finished");


///////////////////////////////////////////////////////////////////////////
///////////////////////////////Functions///////////////////////////////////
///////////////////////////////////////////////////////////////////////////
function lambda(chan) {
	wavelength = newArray("450", "525", "600", "685", "470", "535", "635", "None");
	em = "";
	for (j=0;j<channel_array.length;j++) {
		if (chan != channel_array[j]) {
			i +=1;
		} else {
			em = wavelength[j];
		};
	};
	return em;
};

function get_value(t_dir, target_chan, n, mode) {
	print(t_dir);
	list = getFileList(t_dir);
	f = File.openAsString(t_dir+"\\report"+n+"\\report"+n+".xls");
	ind = indexOf(f, "Dist. (pix.)");
	ind_green = -2;
	new_str_cor = "";
	if (mode == 1) {
		ind_green = indexOf(f, "\nGreen", ind);
		new_str_cor = substring(f, ind_green+7, ind_green+16);
	} else if (mode == 2) {
		ind_green = indexOf(f, "\nRed", ind);
		new_str_cor = substring(file, ind_green+7, ind_green+14);
	};
	//ind_end = indexOf(f, target_chan, ind_green);
	
	//new_str = substring(f, ind_green, ind_end);
	//print(new_str);
	//print(new_str_cor);
	
	green_val1 = substring(new_str_cor, 0, 3);
	green_val2 = substring(new_str_cor, 5);
	green_values = Array.concat(green_val1, green_val2);
	//Array.show(green_values);
	return green_values;
};

function analisarParticulas () {
	//Getting size of particles to analyze
	Dialog.create("Analyze particles - Size");
	Dialog.addNumber("Min Size: ", 0.3);
	Dialog.addNumber("Max Size: ", 2.5);
	Dialog.show();
	minSize = Dialog.getNumber();
	maxSize = Dialog.getNumber();
	
	//recognize beads and name them
	while (pontos == 0 ) {
		run("Analyze Particles...", "size="+minSize+"-"+maxSize+" circularity=0.0-1.0 show=Nothing display exclude clear add slice");
		pontos = roiManager("count");
		//print("Nº of beads: "+pontos);
		if (pontos == 0 ) {
			Dialog.create("Analyze particles - Size");
			Dialog.addNumber("Min Size: ", 0.3);
			Dialog.addNumber("Max Size: ", 2.5);
			Dialog.show();
			minSize = Dialog.getNumber();
			maxSize = Dialog.getNumber();
		}
	}
};

function controlo () {
	Dialog.create("Beads analyzed");
	Dialog.addChoice("Is the analysis correct?", newArray("Yes", "No"));
	Dialog.show();
	resposta = Dialog.getChoice();
	if (resposta == "No") {
		analisarParticulas();
		controlo();
	}
};

function find_max () {
	run("Statistics");
	min = getResult("Min");
	max = getResult("Max");
	//print("Min: "+min);
	//print("Max: "+max);
	
	//choose the highest signal slice
	maior = true;
	while (maior == true) {
		for (i = 1; i < nSlices(); i++) {
			run("Measure");
			maximo = getResult("Max");
			if (maximo < max) {
				setSlice(i);
			} else {
				maior = false;
			}
		}
	};
}

function distance_2d (array_1, array_2) {
	// d = sqrt ( (x2 - x1) ^2 + (y2 - y1)^2)
	d = sqrt( pow(array_2[0]-array_1[0],2) + pow(array_2[1]-array_1[1],2));
	return d
};

function distance_3d (array_1, array_2) {
	// d = sqrt ( (x2 - x1) ^2 + (y2 - y1)^2)
	d = sqrt( pow(array_2[0]-array_1[0],2) + pow(array_2[1]-array_1[1],2) + pow(array_2[2]-array_1[2],2));
	return d
};

function fetch(file, comparison, coord) {
	t1 = indexOf(file, "raw dist px");
	set = indexOf(file, comparison, t1);
	end_comp = indexOf(file, ";", set);
	end_x = indexOf(file, ";", end_comp+1);
	x = substring(file, end_comp+1, end_x);
	x = parseFloat(x);
	end_y = indexOf(file, ";", end_x+1);
	y = substring(file, end_x+1, end_y);
	y = parseFloat(y);
	end_z = indexOf(file, "\n", end_y+1);
	z = substring(file, end_y+1, end_z);
	z = parseFloat(z);
	if (coord == "x") {
		return x;
	} else if (coord == "y") {
		return y;
	} else if (coord == "z") {
		return z;
	} else {
		print("Wrong parameter");
	};
}

/*
SNR = P Qe t / (P Qe t + D t + Nr^2)^1/2
P = photon flux /pixel/second
Qe = CCD Quantum efficiency
t = time in secs
D = dark current
Nr = read noise (electrons rms/pixel)

EMCCD:
P = 0.687 (is the N photons / sec / unit of area
Qe = 92%
D = 0.001
Nr = 49 or <1
*/
