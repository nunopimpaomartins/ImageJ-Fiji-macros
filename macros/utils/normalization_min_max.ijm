print("\\Clear");
title = getTitle();
//getMinAndMax(min, max);
getStatistics(area, mean, min, max, std, histogram);
print("Min: "+min+" Max: "+max);
normalize_mi_ma(title);
getStatistics(area, mean, min, max, std, histogram);
print("Min: "+min+" Max: "+max);

function normalize_mi_ma(x){
	//Min Max normalization between [0,1]
	min_new = 0;
	max_new = 4095;
	selectWindow(x);
	if(bitDepth() == 24){
		exit("Does not work with RGB images");
	} else if(bitDepth()!=32){
		run("32-bit");
	};
	getStatistics(area, mean, min, max, std, histogram);
	getDimensions(width, height, channels, slices, frames);
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			px_value = getPixel(i, j);
			px_nom = (px_value - min) * max_new / (max - min) + min_new;
			setPixel(i, j, px_nom);
		}
	}
}

function normalize_standardization(x){
	/*
	 * x - image to be standardized
	 */
	 selectWindow(x);
	 if(bitDepth() == 24){
	 	exit("Does not work with RGB images");
	 } else if(bitDepth()!=32){
	 	run("32-bit");
	 };
	 getStatistics(area, mean, min, max, std, histogram);
	 getDimensions(width, height, channels, slices, frames);
	 for(i=0;i<=width;i++){
	 	for(j=0;j<height;j++){
	 		px_value = getPixel(i, j);
	 		px_norm = (px_value-mean)/std;
	 		setPixel(i, j, px_norm);
	 	}
	 }
}
