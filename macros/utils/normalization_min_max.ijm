/*
* Macro to normalize images with Rescaling or Min-Max normalization
* User can set new min and max values.
* follows the formula of min-max normalization by rescaling
* Inorm = (I - min) * ( newmax - newmin ) / (max - min)) + newmin
* Author: Nuno Pimpão Martins
*/
print("\\Clear");

function normalize_mi_ma(image, newMin, newMax){
	//Min Max normalization between [newMin, newMax]
	selectWindow(image);
	Stack.getDimensions(width, height, channels, slices, frames);
	if(channels > 1){
		exit("Does not work with multi-channel images");
	};

	if(bitDepth() == 24){
		exit("Does not work with RGB images");
	} else if(bitDepth()!=32){
		run("32-bit");
	};

	Stack.getStatistics(voxelCount, mean, min, max, stdDev)
	factor = (newMax - newMin) / (max - min);

	run("Subtract...", "value="+min+" stack");
	run("Multiply...", "value="+factor+" stack");
	run("Add...", "value="+newMin+" stack");
};

title = getTitle();
Stack.getStatistics(img_voxelCount, img_mean, img_min, img_max, img_stdDev)
print("Min: "+img_min+" Max: "+img_max);
normalize_mi_ma(title, 0, 1);
Stack.getStatistics(img_voxelCount, img_mean, img_min, img_max, img_stdDev)
print("Min: "+img_min+" Max: "+img_max);
print("Done");