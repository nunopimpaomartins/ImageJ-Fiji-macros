/*
 * Macro design to automate PSF FWHM measurements of bead iamges for quality control.
 * author: Nuno Pimpão Martins
 * e-mail: npmartins@igc.gulbenkian.pt
 * IGC 2018
 */

//setup
print("\\Clear");
run("Set Measurements...", "area mean standard modal min centroid feret's integrated median limit display redirect=None decimal=4");
var fs = File.separator;

if (nImages>0) {
	print(nImages+" image(s) found.");
	if (nSlices<=1) {
		exit("Not a stack of images");
	};
} else {
	print("No Image found \n Openning with Bio-Formats...");
	run("Bio-Formats Importer", "open=[] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
};
title = getTitle();
print("Image Title: "+title);
selectWindow(title);

//Check if image is multi-channel and choose the channel where the analysis will be done
if (is("composite")) {
	print("Multi-channel image found.");
	Stack.getDimensions(width, height, channels, slices, frames);
	channel_array = newArray();
	for(i=1;i<=channels;i++){
		channel_array = Array.concat(channel_array, d2s(i, 0));
	};
	Dialog.create("Choose channel.");
	Dialog.addMessage("Choose channel where \n analysis will be done");
	Dialog.addChoice("Channel:", channel_array);
	Dialog.show();
	chan_analysis = d2s(Dialog.getChoice, 0);
	run("Split Channels");
	channel_array = pop(channel_array, chan_analysis);
	for(j=0;j<channel_array.length;j++){
		selectWindow("C"+channel_array[j]+"-"+title);
		close();
	}
} else {
	print ("Not a Multi-channel image, continuing.");
};

//Checking pixel size
run("Properties...");

title2 = getTitle();
print("Green Channel: "+title2);
selectWindow(title2);
resetMinAndMax();
run("Statistics");
min = getResult("Min");
max = getResult("Max");
print("Min: "+min);
print("Max: "+max);

//Detect beads on the MIP
run("Z Project...", "projection=[Max Intensity]");
selectWindow("MAX_"+title2);
setAutoThreshold("MaxEntropy dark");

roiManager("reset");
points = roiManager("count");
analisarParticulas();
controlo();

points = roiManager("count");
selectWindow(title2);
setBatchMode(true);
for (i = 0; i < points ; i++) {
	roiManager("Show All");
	roiManager("Select", i);
	roiManager("Rename", "bead"+(i));
	run("Enlarge...", "enlarge=30 pixel");
	run("Duplicate...", "title=[bead stack "+i+"] duplicate");
	selectWindow(title2);
}
close(title);
close(title2);
close("MAX_"+title2);

if (endsWith(title , ".ome.tif")) {
	newtitle = substring(title, 0, lengthOf(title)-8);
	print(newtitle);
} else if (endsWith(title, ".lif") || endsWith(title,".lsm") || endsWith(title, ".tif")) {
	newtitle = substring(title, 0, lengthOf(title)-4);
	print(newtitle);
} else { //when it ends with .dv
	newtitle = substring(title, 0 , lengthOf(title)-3);
	print(newtitle);
}
title = newtitle;

//Generating PSF reports
Dialog.create("Generate PSF report");
//Dialog.addChoice("NA: ", newArray("0.5", "0.7", "0.75", "0.85", "0.95", "1.15", "1.2", "1.25", "1.3", "1.4", "1.42", "1.44", "1.45", "1.49"));
Dialog.addNumber("NA:", 0.7);
Dialog.addChoice("Microscope type: ", newArray("WideField", "Confocal"));
Dialog.addCheckbox("Savepath:Images in different forlders?", false);
Dialog.show();
//NA = Dialog.getChoice();
NA = Dialog.getNumber();
microscope = Dialog.getChoice();
folders = Dialog.getCheckbox();

if (folders == true) {
	OpenPath = File.directory();
	Parent = File.getParent(OpenPath);
	File.makeDirectory(Parent+fs+"PSF reports"+fs);
	File.makeDirectory(Parent+fs+"PSF reports"+fs+title+fs);
	//SavePath = getDirectory("Choose a Directory to save PDFs");
	SavePath = Parent+fs+"PSF reports"+fs+title+fs;
	print("Saving to: "+SavePath);
} else {
	OpenPath = File.directory();
	File.makeDirectory(OpenPath+fs+"PSF reports"+fs);
	File.makeDirectory(OpenPath+fs+"PSF reports"+fs+title+fs);
	//SavePath = getDirectory("Choose a Directory to save PDFs");
	SavePath = OpenPath+fs+"PSF reports"+fs+title+fs;
	print("Saving to: "+SavePath);
}

for (i = 0; i < nImages; i++) {
	selectWindow("bead stack "+i);
	run("Generate PSF report", "microscope="+microscope+" wavelength=525 na="+NA+" pinhole=1 text1=[Sample infos: ] text2=[Comments: ] scale=5 save save=["+SavePath+"report"+i+".pdf]");	
}

dir = SavePath;
print(dir);
list = getFileList(dir);
nr = list.length/2;

//fetch x values
for (i=0; i<nr; i++) {
	string = File.openAsString(dir+fs+"report"+i+fs+"report"+i+"_summary.xls");
	b = indexOf(string, "x");
	c = indexOf(string, " µm", b);
	value = substring(string, b+2, c); //The +2 is the gap until the value.
	print("x "+i+": "+value);
	File.append(value+", ", dir+"log x.csv");
}

//fetch y values
for (i=0; i<nr; i++) {
	string = File.openAsString(dir+fs+"report"+i+fs+"report"+i+"_summary.xls");
	b = indexOf(string, "y");
	c = indexOf(string, " µm", b);
	value = substring(string, b+2, c);
	print("y "+i+": "+value);
	File.append(value+", ", dir+"log y.csv");
}

//fetch z values
for (i=0; i<nr; i++) {
	string = File.openAsString(dir+fs+"report"+i+fs+"report"+i+"_summary.xls");
	b = indexOf(string, "z");
	c = indexOf(string, " µm", b);
	value = substring(string, b+2, c);
	print("z "+i+": "+value);
	File.append(value+", ", dir+"log z.csv");
}
print("Macro Done.");
run("Close All");
setBatchMode(false);

function analisarParticulas () {
	//Getting size of particles to analyze
	Dialog.create("Analyze particles - Size");
	Dialog.addNumber("Min Area: ", 0.1);
	Dialog.addNumber("Max Area: ", 1);
	Dialog.show();
	minSize = Dialog.getNumber();
	maxSize = Dialog.getNumber();
	
	//recognize beads and name them
	while (points == 0 ) {
		run("Analyze Particles...", "size="+minSize+"-"+maxSize+" circularity=0.0-1.0 show=Nothing display exclude clear add slice");
		points = roiManager("count");
		print("Nº de beads: "+points);
		if (points == 0 ) {
			Dialog.create("Analyze particles - Size");
			Dialog.addNumber("Min Area: ", 0.1);
			Dialog.addNumber("Max Area: ", 1);
			Dialog.show();
			minSize = Dialog.getNumber();
			maxSize = Dialog.getNumber();
		}
	}
}

function controlo () {
	Dialog.create("Beads analyzed");
	Dialog.addChoice("Is the analysis correct?", newArray("Yes", "No"));
	Dialog.show();
	resposta = Dialog.getChoice();
	if (resposta == "No") {
		analisarParticulas();
		controlo();
	}
}

function pop(array, position) {
	front = Array.slice(array, 0, position-1);
	end = Array.slice(array, position, array.length);
	new_array = Array.concat(front, end);
	return new_array;
};