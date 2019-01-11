print("\\Clear");
run("Set Measurements...", "area mean standard modal min centroid center integrated median limit display redirect=None decimal=4");
roiManager("reset");
run("Clear Results");

fs = File.separator;
//Setting up arrays
channel_array = newArray("DAPI", "GFP", "RFP", "Cy5", "CFP", "YFP", "mCherry", "None");
NA = newArray("0.5", "0.7", "0.75", "0.85", "0.95", "1.15", "1.2", "1.25", "1.3", "1.4", "1.42", "1.44", "1.45", "1.49");
NA_20x = newArray("0.5", "0.7", "0.75", "0.8", "1.0");
NA_40x = newArray("0.7", "0.75", "0.85", "1.25", "1.3");
NA_60x = newArray("1.2", "1.4", "1.42");
NA_100x = newArray("1.3", "1.4", "1.45", "1.49");

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

Stack.getDimensions(width, height, chan_number, slices, frames);
print("Number of chan_number: "+chan_number);

//window to get define details and parameters
Dialog.create("Info setup.");
Dialog.addMessage("Choose existing chan_number and their order");
Dialog.addMessage("Image name: "+title+"");
Dialog.addMessage("Image Directory: "+dir);
Dialog.addMessage("Current image dimensions: \nWidth: "+width+" \nHeight: "+height+" \nChannels: "+chan_number+" \nZ Slices:"+slices+" \nT frames: "+frames);
Dialog.addChoice("Channel 1", channel_array, channel_array[0]);
Dialog.addChoice("Channel 2", channel_array, channel_array[1]);
Dialog.addChoice("Channel 3", channel_array, channel_array[2]);
Dialog.addChoice("Channel 4", channel_array, channel_array[3]);
Dialog.addRadioButtonGroup("Microscope type", newArray("WideField", "Confocal"), 1, 2, "WideField");
Dialog.addChoice("Objective NA", NA);
Dialog.addRadioButtonGroup("Save reports in same folder as images? \n (alternatively, will be saved on the parent folder)", newArray("Yes", "No"), 1, 2, "Yes");
Dialog.addRadioButtonGroup("Save final concatenated arrays?", newArray("Yes", "No"), 1, 2, "Yes");
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
	File.makeDirectory(Parent+fs+"Co-loc reports"+fs);
	File.makeDirectory(Parent+fs+"Co-loc reports"+fs+title+fs);
	save_dir = Parent+fs+"Co-loc reports"+fs+title+fs;
	print("Saving to: "+save_dir);
} else {
	File.makeDirectory(dir+fs+"Co-loc reports"+fs);
	File.makeDirectory(dir+fs+"Co-loc reports"+fs+title+fs);
	save_dir = dir+fs+"Co-loc reports"+fs+title+fs;
	print("Saving to: "+save_dir);
};

/*if (chan1 == chan2 || chan1 == chan3 || chan1 == chan4 || chan2 == chan3 || chan2 == chan4 || chan3 == chan4) {
	exit("You cannot have 2 equal channels!");
};*/

/*
if (chan_number > 3) {
	Stack.setChannel(1);
	print("Setting channel 1 to initialize.");
} else {
	Stack.setChannel(0);
	print("Setting channel 0 to initialize.");
};
*/

selectWindow(filename);
run("Z Project...", "projection=[Max Intensity]");
//find_max();
if(chan_number < 4) {
	Stack.setChannel(2);
} else {
	Stack.setChannel(3);
};

setAutoThreshold("MaxEntropy dark");
roiManager("reset");
pontos = roiManager("count");
analisarParticulas();
controlo();

selectWindow("MAX_"+filename);
close();
selectWindow(filename);

setBatchMode(true);
beads = roiManager("count");
num_length = lengthOf(toString(beads));
for (i = 0; i < beads ; i++) {
	value_array=newArray();
	showProgress(-i/beads);
	selectWindow(filename);
	roiManager("Show All");
	roiManager("Select", i);
	roiManager("Rename", "bead"+(i));
	run("Enlarge...", "enlarge=5 pixel");
	run("Duplicate...", "title=[bead stack "+IJ.pad(i, num_length)+"] duplicate");
	//selectWindow(title);
	table_name = "[bead_coord_list_bead_"+IJ.pad(i, num_length)+"]";
	table_name_2 = "bead_coord_list_bead_"+IJ.pad(i, num_length);
	run("New... ", "name="+table_name+" type=Table");
	print(table_name, "channel coord, x , y, z,");
	selectWindow("bead stack "+IJ.pad(i, num_length));

	window_array = newArray(chan_number);
	run("Split Channels");
	for (j=1; j<=chan_number; j++) {
		selectWindow("C"+j+"-bead stack "+IJ.pad(i, num_length));
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
		window_array[j-1] = newtitle;
	};

	for(k=0;k<chan_number;k++) {
		selectWindow(window_array[k]);
		run("Select None");
		run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
		run("Z Project...", "type=[Max Intensity]");
		setAutoThreshold("Otsu dark");
		run("Analyze Particles...", "size=1-1500 pixel display clear slice");
		x = getResult("XM");
		y = getResult("YM");
		close("MAX_"+window_array[k]);

		selectWindow(window_array[k]);
		run("Reslice [/]...", "output="+pixelSize+" start=Left rotate avoid");
		run("Z Project...", "type=[Max Intensity]");
		setAutoThreshold("Otsu dark");
		run("Analyze Particles...", "size=1-1500 pixel display clear slice");
		z = getResult("XM");
		close("Reslice of "+window_array[k]);
		close("MAX_Reslice of "+window_array[k]);
		print(table_name, window_array[k]+", "+x+", "+y+", "+z);
		values = ""+x+"; "+y+"; "+z;
		value_array = Array.concat(value_array, values);
		//Array.show(value_array);
	};

	fac1 = factorialize(chan_number);
	fac2 = factorialize(2);
	fac3 = factorialize(chan_number-2);
	combinations=fac1/(fac2*fac3);
	//print("Combinations of channels: "+combinations);

	counter = 0;
	print(table_name, "raw dist px, x, y, z");
	//while(counter<combinations){
	for(l=1;l<window_array.length;l++){
		for(o=0;o<l;o++){
			channel_1=newArray();
			channel_2=newArray();
			channel_1 = split(value_array[o], ";");
			//Array.show(channel_1);
			channel_2 = split(value_array[l], ";");

			//pixel shift
			print(table_name, window_array[o]+"vs"+window_array[l]+", "+(parseFloat(channel_1[0])-parseFloat(channel_2[0]))+", "+(parseFloat(channel_1[1])-parseFloat(channel_2[1]))+", "+(parseFloat(channel_1[2])-parseFloat(channel_2[2])));
		};
	};
	//	counter+=1;
	//};

	//euclidian distance calculation in 2d
	print(table_name, "euclidian 2d, px, um");
	for(l=1;l<window_array.length;l++){
		for(o=0;o<l;o++){
			channel_1=newArray();
			channel_2=newArray();
			channel_1 = split(value_array[o], ";");
			//Array.show(channel_1);
			channel_2 = split(value_array[l], ";");

			d1=distance_2d(channel_1, channel_2);
			print(table_name, window_array[o]+"vs"+window_array[l]+","+d1+","+(d1*pixelSize));
		};
	};

	//euclidian distance calculation in 3d
	print(table_name, "euclidian 3d, px, um");
	for(l=1;l<window_array.length;l++){
		for(o=0;o<l;o++){
			channel_1=newArray();
			channel_2=newArray();
			channel_1 = split(value_array[o], ";");
			channel_2 = split(value_array[l], ";");

			d2=distance_3d(channel_1, channel_2);
			print(table_name, window_array[o]+"vs"+window_array[l]+","+d2+","+(d2*pixelSize));
		};
	};

	updateResults();
	selectWindow(table_name_2);

	increment = 0;
	save_name = table_name_2;
	if(File.exists(save_dir+fs+save_name+".csv")==true) {
		do {
			increment+=1;
			save_name = table_name_2+"_"+increment;
		} while(File.exists(save_dir+fs+save_name+".csv")==true);
		saveAs("Results", save_dir+fs+save_name+".csv");
	} else {
		saveAs("Results", save_dir+fs+save_name+".csv");
	};

	for(p=0;p<window_array.length;p++){
		selectWindow(window_array[p]);
		close();
	};
	print(table_name, "\\Close");
};
setBatchMode(false);
//list = getFileList(save_dir);
//print(list.length);

/////////////////////////////////////////////////////////////////////
//////////////Retrieve values from calculated differences////////////
//////////////uses fetch function////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//print("\nDAPI vs GFP");
print("\n---------------------------------");
print("Summary and Concatenated values");

table_list = getFileList(save_dir);
//print(table_list.length);
//Array.show(table_list);

for(l=1;l<window_array.length;l++) {
	for(o=0;o<l;o++){
		print("\n "+window_array[o]+"_vs_"+window_array[l]);
		chan1=window_array[o];
		chan2=window_array[l];
		content_array_x=newArray();
		content_array_x_name = chan1+"vs"+chan2+"_x_values";
		content_array_y=newArray();
		content_array_y_name = chan1+"vs"+chan2+"_y_values";
		content_array_z=newArray();
		content_array_z_name = chan1+"vs"+chan2+"_z_values";
		for(q=0;q<table_list.length;q++){
			//print(table_list[q]);
			table=File.openAsString(save_dir+fs+table_list[q]);
			x_value = parseFloat(fetch(table, chan1+"vs"+chan2, "x"));
			content_array_x = Array.concat(content_array_x, x_value);
		};
		if (show_array == "Yes") {
			Array.show(content_array_x);
			saveAs("Results", save_dir+fs+content_array_x_name+".csv");
			run("Close");
		};
		Array.getStatistics(content_array_x, min, max, mean, stdDev);
		print("Mean X: "+mean);
		print("stdDev X: "+stdDev);

		for(q=0;q<table_list.length;q++){
			table=File.openAsString(save_dir+fs+table_list[q]);
			y_value = parseFloat(fetch(table, chan1+"vs"+chan2, "y"));
			content_array_y = Array.concat(content_array_y, y_value);
		};
		if (show_array == "Yes") {
			Array.show(content_array_y);
			saveAs("Results", save_dir+fs+content_array_y_name+".csv");
			run("Close");
		};
		Array.getStatistics(content_array_y, min, max, mean, stdDev);
		print("Mean Y: "+mean);
		print("stdDev Y: "+stdDev);

		for(q=0;q<table_list.length;q++){
			table=File.openAsString(save_dir+fs+table_list[q]);
			z_value = parseFloat(fetch(table, chan1+"vs"+chan2, "z"));
			content_array_z = Array.concat(content_array_z, z_value);
		};
		if (show_array == "Yes") {
			Array.show(content_array_z);
			saveAs("Results", save_dir+fs+content_array_z_name+".csv");
			run("Close");
		};
		Array.getStatistics(content_array_z, min, max, mean, stdDev);
		print("Mean Z: "+mean);
		print("stdDev Z: "+stdDev);
	};
};

selectWindow("Log");
saveAs("Text", save_dir+fs+title+"_log.txt");
run("Close All");
print("Macro Finished");
beep();


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
	f = File.openAsString(t_dir+fs+"report"+n+fs+"report"+n+".xls");
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
			Dialog.addNumber("Min Size (area): ", 0.3);
			Dialog.addNumber("Max Size (area): ", 2.5);
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

function fetch(string, comparison, coord) {
	t1 = indexOf(string, "raw dist px,");
	set = indexOf(string, comparison, t1);
	end_comp = indexOf(string, ",", set);
	end_x = indexOf(string, ",", end_comp+1);
	x_string = substring(string, end_comp+1, end_x);
	x_float = parseFloat(x_string);
	end_y = indexOf(string, ",", end_x+1);
	y_string = substring(string, end_x+1, end_y);
	y_float = parseFloat(y_string);
	end_z = indexOf(string, "\n", end_y+1);
	z_string = substring(string, end_y+1, end_z);
	z_float = parseFloat(z_string);
	if (coord == "x") {
		return x_float;
	} else if (coord == "y") {
		return y_float;
	} else if (coord == "z") {
		return z_float;
	} else {
		print("Wrong parameter");
	};
};

function factorialize(number) {
	if (number==1 || number == 0) {
		return 1;
	} else {
		sum=1;
		for(i=number;i>0;i--){
			sum = sum*i;
		};
		return parseInt(sum);
	};
};

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
