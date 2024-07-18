/*
* Set of functions to measure focus in an image
* accoding to REF, images need to be downscaled to prevent noise related problems in non spectral metrics
* my calculations: 4x - factor 4; 10x - factor x; 20x - factor y
*/
startTime = getTime();
print("\\Clear");
fs = File.separator;
run("Clear Results");
roiManager("reset");
run("Set Measurements...", "area mean modal min centroid shape feret's integrated median limit nan redirect=None decimal=3");

// Getting the full time to be used in name of final csv file.
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
fullTime = toString(year)+toString(IJ.pad(month, 2))+toString(IJ.pad(dayOfMonth,2))+"_"+toString(IJ.pad(hour,2))+toString(IJ.pad(minute,2))+toString(IJ.pad(second,2));

//----------------------------------------------------------------------------------//
//------------------------------ Directory setup -----------------------------------//
//----------------------------------------------------------------------------------//
imgDir = getDirectory("Choose image directoy.");
//imgDir = "/mnt/486CEDE06CEDC8B0/Data/3dliver_local/Jose/201001_SM/NPC4x/temp/";
//imgDir = "D:\\Data\\3dliver_local\\Jose\\201001_SM\\NPC4x\\temp\\";
print("Image folder: "+imgDir);
fileList = getFileList(imgDir);
fileList_length = fileList.length;
print("Number of files in List: "+fileList_length);

//----------------------------------------------------------------------------------//
//------------------------------ start image Analysis ------------------------------//
//----------------------------------------------------------------------------------//
pxSize = 1.6250;
pxDepth = 1;
pxUnit = "um";

setBatchMode(true);
for(i=0; i<fileList_length;i++) {
	if(endsWith(fileList[i], ".tif")){
		open(fileList[i]);

		print("_____________");
		imageName = getTitle();
		print("Image full name: "+imageName);
		imageTitle = substring(imageName, 0, indexOf(imageName, ".tif"));
		print("Image name, no ext: "+imageTitle);

		//check pixel size and correct if needed
		getVoxelSize(rawPxwidth, rawPxheight, rawPxdepth, rawUnit);
		if(rawUnit != "µm" && rawPxwidth != pxSize && rawPxheight != pxSize) {
			//print("Px units differ: \nPx width: "+rawPxwidth+" height: "+rawPxheight+" unit: "+rawUnit+" \n Setting new units and px values...");
			setVoxelSize(pxSize, pxSize, pxDepth, pxUnit);
			//print("New Px width: "+pxSize+" height: "+pxSize+" unit: "+pxUnit);
		}

		run("Split Channels");

        sinusoids = "C1-"+imageName;
        selectWindow(sinusoids);
        binnedSinusoids = sinusoids+"_binned";
        run("Duplicate...", "title=["+binnedSinusoids+"]");
        selectWindow(binnedSinusoids);
        run("Bin...", "x=4 y=4 bin=Average");

		focusMetrics = newArray(8);
		focusMetrics[0] = brenner(binnedSinusoids);
		focusMetrics[1] = absoluteLaplacian(binnedSinusoids);
		focusMetrics[2] = squaredLaplacian(binnedSinusoids);
		focusMetrics[3] = totalVariation(binnedSinusoids);
		focusMetrics[4] = tenegrad(binnedSinusoids);
		focusMetrics[5] = vollathf4(binnedSinusoids);
		focusMetrics[6] = vollathf5(binnedSinusoids);
		focusMetrics[7] = symmetricVollathf4(binnedSinusoids);

        currentRow = nResults;
        setResult("Label", currentRow, imageTitle);
        setResult("Brenner", currentRow, focusMetrics[0]);
        setResult("Abs Laplacian", currentRow, focusMetrics[1]);
        setResult("Squared Laplacian", currentRow, focusMetrics[2]);
        setResult("Total Variation", currentRow, focusMetrics[3]);
        setResult("Tenegrad", currentRow, focusMetrics[4]);
        setResult("VollathF4", currentRow, focusMetrics[5]);
        setResult("VollathF5", currentRow, focusMetrics[6]);
        setResult("Symmetric Vollath F4", currentRow, focusMetrics[7]);
        updateResults();

		focusScore = 0;
		focusThreshold = newArray(2700, 15, 50000, 10, 50000, 500, 500, 2000);
		for(focusIdx = 0; focusIdx < focusMetrics.length; focusIdx++) {
			if(focusMetrics[focusIdx] > focusThreshold[focusIdx]) {focusScore += 1;} else {focusScore += 0;};
		};
		focusScore /= focusMetrics.length;
		setResult("focusScore", currentRow, focusScore);
		if(focusScore > 0.7) {setResult("In focus?", currentRow, "Yes");} else {setResult("In focus?", currentRow, "No");};

        run("Close All");
    };
};
setBatchMode("exit and display");
endTime = getTime();
print("Analysis time: "+(endTime-startTime)/1000+" s");
print("Done");
beep();

/*
* Differential image quality metrics
*/
function brenner(image) {
    selectWindow(image);
    imageWidth = getWidth();
    imageHeight = getHeight();
    nPixels = imageWidth*imageHeight;
    tempSum = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum += pow(getPixel(ii,jj-1)-getPixel(ii,jj+1), 2);
        }
    }
    brennerValue = tempSum/nPixels;
    return brennerValue;
};

function absoluteLaplacian(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum += abs(2*getPixel(ii,jj) - getPixel(ii-1, jj) - getPixel(ii+1, jj)) + abs(2*getPixel(ii,jj) - getPixel(ii, jj-1) - getPixel(ii, jj+1));
        }
    }
    absLaplaceValue = tempSum/nPixels;
    return absLaplaceValue;
};

function squaredLaplacian(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum += pow((8*getPixel(ii,jj) - getPixel(ii-1, jj) - getPixel(ii+1, jj) - getPixel(ii, jj-1) - getPixel(ii, jj+1) - getPixel(ii-1, jj-1) - getPixel(ii+1, jj+1) - getPixel(ii+1, jj-1) - getPixel(ii-1, jj+1)), 2);
        }
    }
    sqLaplacianValue = tempSum / nPixels;
    return sqLaplacianValue;
};

function totalVariation(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum += sqrt(pow(getPixel(ii+1,jj) - getPixel(ii-1,jj) ,2) + pow(getPixel(ii,jj+1) - getPixel(ii,jj-1) ,2));
        }
    }
    totalVariationValue = tempSum/nPixels;
    return totalVariationValue
};

function tenegrad(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum += (pow(sobelHorizontal(ii,jj) ,2) + pow(sobelVertical(ii,jj) ,2));
        }
    }
    tenegradValue = tempSum/nPixels;
    return tenegradValue;
};

function sobelHorizontal(x, y) {
    sobelH = getPixel(x+1, y-1) + 2*getPixel(x+1, y) + getPixel(x+1, y+1) - getPixel(x-1, y-1) - 2*getPixel(x-1, y) - getPixel(x-1, y+1);
    return sobelH;
};

function sobelVertical(x, y) {
    sobelV = getPixel(x-1, y+1) + 2*getPixel(x, y+1) + getPixel(x+1, y+1) - getPixel(x-1, y-1) - 2*getPixel(x, y-1) - getPixel(x+1, y-1);
    return sobelV;
};

/*
* Correlative image quality metrics
*/

function vollathf4(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum += getPixel(ii,jj) * (getPixel(ii+1, jj) - getPixel(ii+2, jj));
        }
    }
    vollathf4Value = tempSum/nPixels;
    return vollathf4Value;
};

function vollathf5(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum1st = 0;
    tempSum2nd = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum1st += getPixel(ii,jj) * getPixel(ii+1, jj);
            tempSum2nd += getPixel(ii,jj);
        }
    }
    arg2 = pow(tempSum2nd, 2)/nPixels;
    vollathf5Value = (tempSum1st - arg2)/nPixels;
    return vollathf5Value;
};

function symmetricVollathf4(image){
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;
    tempSum1 = 0;
    tempSum2 = 0;
    tempSum3 = 0;
    tempSum4 = 0;
    for(ii=1; ii<imageWidth-1; ii++) {
        for(jj=1; jj<imageHeight-1; jj++) {
            tempSum1 += getPixel(ii,jj) * (getPixel(ii+1, jj) - getPixel(ii+2, jj));
            tempSum2 += getPixel(ii,jj) * (getPixel(ii-1, jj) - getPixel(ii-2, jj));
            tempSum3 += getPixel(ii,jj) * (getPixel(ii, jj+1) - getPixel(ii, jj+2));
            tempSum4 += getPixel(ii,jj) * (getPixel(ii, jj-1) - getPixel(ii, jj-2));
        }
    }
    symmetricVollathValue = (abs(tempSum1) + abs(tempSum2) + abs(tempSum3) + abs(tempSum4))/nPixels;
    return symmetricVollathValue;
};
