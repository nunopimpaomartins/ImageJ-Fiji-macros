/*
 * Lif to tiff
 * Macro to open and save different image formats in a seperate folder,
 * where we can choose between saving as tif or ome.tif (later using Bio-formats exporter)
 * autor: Nuno Pimpão Martins
 * IGC 2015-2018
 *
 * changelog at the end of the file.
 */

setBatchMode(true); //can make the macro faster by not displaying the files
print("\\Clear");

run("Bio-Formats Macro Extensions"); //enables Bio-Formats command lines
fs = File.separator;

batch = getBoolean("Convert multiple files? (Batch Mode)");
if (batch == true){
	print("Batch Mode: On");
	directory = getDirectory("Choose folder to convert");
	print("Parent folder: "+directory);
	filelist = getFileList(directory);

	if (endsWith(directory, "\\")==true) {
		directory = substring(directory, 0, lengthOf(directory)-1);
	};

	series_array = newArray();
	total_series = 0;
	images = 0;
	for(j=0;j<filelist.length;j++){
		if(endsWith(filelist[j], ".lif")==true || endsWith(filelist[j], ".nd")==true || endsWith(filelist[j], ".nd2")==true) {
			Ext.setId(directory+fs+filelist[j]);
			Ext.getSeriesCount(seriesCount);
			series_array = Array.concat(series_array, filelist[j]+"; "+seriesCount);
			total_series += seriesCount;
			images += 1;
		};
	};

	Dialog.create("Lif to Tiff (Batch Mode)");
	Dialog.addMessage("Check destination save folder and format.");
	Dialog.addMessage("Parent folder: "+directory);
	Dialog.addMessage("Number of items in folder: "+filelist.length);
	Dialog.addMessage("Number of image files in folder: "+images);
	Dialog.addMessage("Total number of series in folder: "+total_series);
	Dialog.addChoice("File format: ", newArray("tiff", "ome tiff"));
	Dialog.show();
	format = Dialog.getChoice();
	print("Saving format: "+format);

	current_series = 0;
	for(k=0;k<filelist.length;k++) {
		if (endsWith(filelist[k], "/")==false && endsWith(filelist[k], "\\")==false && endsWith(filelist[k], fs)==false) {
			filename = filelist[k];
			print("________________\nFilename: "+filename);
			if (endsWith(filename, ".lif") == true) {
				title = substring(filename, 0, indexOf(filename, ".lif"));
			} else if(endsWith(filename, ".nd") == true) {
				title = substring(filename, 0, indexOf(filename, ".nd"));
			} else if(endsWith(filename, ".nd2") == true) {
				title = substring(filename, 0, indexOf(filename, ".nd2"));
			};

			File.makeDirectory(directory+fs+title+" "+format+fs);
			save_dir = directory+fs+title+" "+format+fs;
			print("Save directory: "+save_dir);


			if (nImages < 1) {
				Ext.setId(directory+fs+filelist[k]);
				Ext.getSeriesCount(seriesCount);
				for (m=1; m <= seriesCount; m++) {
					run("Bio-Formats Importer", "open=["+directory+fs+filelist[k]+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+m+"");
					title = getTitle();
					title_part = charPurge(title);
					print("_\n Current file series nr: "+IJ.pad(m, lengthOf(toString(seriesCount)))+" of "+seriesCount);
					print("Original title: "+title);
					print("New Title (without special charaters): "+title_part);
					print("Saving to: "+save_dir);
					if (format == "tiff") {
						saveAs("Tiff", save_dir+fs+title_part+"_series_"+IJ.pad(m, lengthOf(toString(seriesCount)))+".tif");
					} else if (format == "ome tiff"){
						run("Bio-Formats Exporter", "save=["+save_dir+fs+title_part+"_series_"+IJ.pad(m, lengthOf(toString(seriesCount)))+".ome.tif] compression=Uncompressed");
					}
					close();
					current_series += 1;
					showProgress(current_series/total_series);
				};
			};
			run("Close All");
		};
	};
} else {
	print("Batch Mode: Off");
	file = File.openDialog("Choose a file");
	Ext.setId(file);
	Ext.getSeriesCount(seriesCount);
	print("Number of Series: "+seriesCount);

	directory = File.directory;
	filename = File.nameWithoutExtension;

	Dialog.create("Lif to Tiff");
	Dialog.addMessage("Check original folder and destination save folder to convert files.");
	Dialog.addMessage("Filename: "+filename);
	Dialog.addMessage("Folder: "+directory);
	Dialog.addMessage("Number of series in file: "+seriesCount);
	Dialog.addMessage("Images will be exported to: "+directory+fs+filename+" tiff series"+fs);
	Dialog.addString("Change folder name (optional): ", filename, 40);
	Dialog.addChoice("File format: ", newArray("tiff", "ome tiff"));
	Dialog.show();
	save_dir_name = Dialog.getString();
	format = Dialog.getChoice();

	if (endsWith(directory, "\\")==true) {
		directory = substring(directory, 0, lengthOf(directory)-1);
	};

	File.makeDirectory(directory+fs+save_dir_name+" "+format+" series");
	save_dir = directory+fs+filename+" "+format+" series";
	print("Parent directory:"+directory);
	print("Saving format: "+format);
	print("Save directory: "+save_dir);

	if (nImages < 1) {
		for (i=1; i <= seriesCount; i++) {
			run("Bio-Formats Importer", "open=["+file+"] autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+i+"");
			title = getTitle();
			title_part = charPurge(title);
			print("_\n Series nr: "+i+" of "+seriesCount);
			print("Original title: "+title);
			print("New Title (without special charaters): "+title_part);
			print("Saving to: "+save_dir);
			if (format == "tiff") {
				saveAs("Tiff", save_dir+fs+title_part+"_series_"+IJ.pad(i, lengthOf(toString(seriesCount)))+".tif");
			} else if (format == "ome tiff"){
				run("Bio-Formats Exporter", "save=["+save_dir+fs+title_part+"_series_"+IJ.pad(i, lengthOf(toString(seriesCount)))+".ome.tif] compression=Uncompressed");
			}
			close();
			showProgress(i/seriesCount);
		};
	};
	run("Close All");
};

print("_____\nMacro Finished");
setBatchMode(false);


function charPurge(string) {
	string = toLowerCase(string);
	while(indexOf(string, "(")>=0 || indexOf(string, ")") >= 0 || indexOf(string, "/") >= 0 || indexOf(string, "\\") >= 0 || indexOf(string, "\"")>=0 || indexOf(string, " ")>=0) {
		if (indexOf(string, "(")>=0) {
			string = replace(string, "(", "_");
		} else if (indexOf(string, ")")>=0) {
			string = replace(string, ")", "_");
		} else if (indexOf(string, "\\")>=0) {
			string = replace(string, "\\", "_");
		} else if (indexOf(string, "/")>=0) {
			string = replace(string, "/", "_");
		} else if (indexOf(string, "\"")>=0) {
			string = replace(string, "\"", "_");
		} else if (indexOf(string, " ")>=0) {
			string = replace(string, " ", "_");
		};
	};
	while(indexOf(string, ".tif")>=0 || indexOf(string, ".tiff") >= 0 || indexOf(string, ".lif") >= 0 || indexOf(string, ".nd") >= 0 || indexOf(string, ".nd2")>=0 ) {
		if (indexOf(string, ".tif")>=0) {
			string = replace(string, ".tif", "_");
		} else if (indexOf(string, ".tiff") >=0) {
			string = replace(string, ".tiff", "_");
		} else if (indexOf(string, ".lif")>=0) {
			string = replace(string, ".lif", "_");
		} else if (indexOf(string, ".nd") >=0) {
			string = replace(string, ".nd", "_");
		} else if (indexOf(string, ".nd2") >= 0) {
			string = replace(string, ".nd2", "_");
		};
	};
	return string;
};

/*
 * Changelog
 * --
 * 2019-05-28 v1.9: Replaced all blank spaces by underscores.
 * 2018-05-08 v1.8: Added batch file conversion mode.
 * 2018-04-27 v1.7: Added zero (0) padding to save file name. To prevent problems with stitching.
 * 2017-07-26 v1.6:
 * - works with files in .nd (MetaMorph), .nd2 (NIS Elements) and .lif (Leica) files.
 * - fixed a bug that would stop the macro while saving in OME Tiff format. Directory had an extra "\"
 * - new: renames files to exclude some special characters that could cause problems
 * - rearranged the code, it is now simpler and more compact
 * 2017-03-27 v1.4: changes to file separator to prevent OS problems
 * 2016-12-07 v1.3: bug fix and slight corrections
 * 2016-10-17 v1.2: bug fixes while saving series with no title
 * 2016-05-06 v1.1:
 * - added a new GUI and the ability to change name of the destination folder
 * - now you can choose if you want to save as tiff or ome tiff
 * - added progress bar
 * 2015-06-16 v1: slight rework to the saving name title to prevent overwriting files with the same name. Added "_series number" to the save name.
 */
