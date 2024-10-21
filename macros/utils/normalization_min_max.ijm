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
	if(bitDepth() == 24){
		exit("Does not work with RGB images");
	} else if(bitDepth()!=32){
		run("32-bit");
	};
	
	Stack.getStatistics(voxelCount, mean, min, max, stdDev)
	dividend = newMax - newMin;
	divisor = max - min;
	factor = dividend / divisor;

	run("Subtract...", "value="+min+" stack");
	run("Multiply...", "value="+factor+" stack");
	run("Add...", "value="+newMin+" stack");
}

title = getTitle();
getStatistics(area, mean, min, max, std, histogram);
print("Min: "+min+" Max: "+max);
normalize_mi_ma(title);
getStatistics(area, mean, min, max, std, histogram);
print("Min: "+min+" Max: "+max);
print("Done");