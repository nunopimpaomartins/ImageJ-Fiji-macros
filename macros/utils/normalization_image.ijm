print("\\Clear");
title = getTitle();
//getMinAndMax(min, max);
normalize_mi_ma(title);
//normalize_mi_ma_sample(title, 0, 160);
//normalize_standardization(title);
//normalize_standardization_sample(title, 13.683, 14.605);

function normalize_mi_ma(x){
	//Min Max normalization between [0,1]
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
			px_nom = (px_value - min) / (max - min);
			setPixel(i, j, px_nom);
		}
	}
};

function normalize_mi_ma_sample(x, mi, ma){
	//Min Max normalization between [0,1]
	selectWindow(x);
	if(bitDepth() == 24){
		exit("Does not work with RGB images");
	} else if(bitDepth()!=32){
		run("32-bit");
	};
	getDimensions(width, height, channels, slices, frames);
	for(i=0;i<width;i++){
		for(j=0;j<height;j++){
			px_value = getPixel(i, j);
			px_nom = (px_value - mi) / (ma - mi);
			setPixel(i, j, px_nom);
		}
	}
};

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
};

function normalize_standardization_sample(x, mu, sigma){
	/*
	 * x - image to be standardized
	 */
	 selectWindow(x);
	 if(bitDepth() == 24){
	 	exit("Does not work with RGB images");
	 } else if(bitDepth()!=32){
	 	run("32-bit");
	 };
	 getDimensions(width, height, channels, slices, frames);
	 for(i=0;i<=width;i++){
	 	for(j=0;j<height;j++){
	 		px_value = getPixel(i, j);
	 		px_norm = (px_value-mu)/sigma;
	 		setPixel(i, j, px_norm);
	 	}
	 }
};