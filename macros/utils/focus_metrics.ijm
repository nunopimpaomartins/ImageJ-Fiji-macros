/*
* Set of functions to measure focus in an image
* accoding to REF, images need to be downscaled to prevent noise related problems in non spectral metrics
* my calculations: 4x - factor 4; 10x - factor x; 20x - factor y
*/
currentRow = nResults;
imageName = getTitle();
setResult("Label", currentRow, imageName);
setResult("Brenner", currentRow, brenner(imageName));
setResult("Abs Laplacian", currentRow, absoluteLaplacian(imageName));
setResult("Squared Laplacian", currentRow, squaredLaplacian(imageName));
setResult("Total Variation", currentRow, totalVariation(imageName));
setResult("Tenegrad", currentRow, tenegrad(imageName));
setResult("VollathF4", currentRow, vollathf4(imageName));
setResult("VollathF5", currentRow, vollathf5(imageName));
setResult("Symmetric Vollath F4", currentRow, symmetricVollathf4(imageName));

/*
* Differential image quality metrics
*/
function brenner(image) {
    selectWindow(image);
    imageWidth = getWidth();
    imageHeight = getHeight();
    nPixels = imageWidth*imageHeight;

    tempSum = 0;
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum += pow(getPixel(i,j-1)-getPixel(i,j+1), 2);
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
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum += abs(2*getPixel(i,j) - getPixel(i-1, j) - getPixel(i+1, j)) + abs(2*getPixel(i,j) - getPixel(i, j-1) - getPixel(i, j+1));
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
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum += pow((8*getPixel(i,j) - getPixel(i-1, j) - getPixel(i+1, j) - getPixel(i, j-1) - getPixel(i, j+1) - getPixel(i-1, j-1) - getPixel(i+1, j+1) - getPixel(i+1, j-1) - getPixel(i-1, j+1)), 2);
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
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum += sqrt(pow(getPixel(i+1,j) - getPixel(i-1,j) ,2) + pow(getPixel(i,j+1) - getPixel(i,j-1) ,2));
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
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum += (pow(sobelHorizontal(i,j) ,2) + pow(sobelVertical(i,j) ,2));
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
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum += getPixel(i,j) * (getPixel(i+1, j) - getPixel(i+2, j));
        }
    }
    vollathf4Value = tempSum/nPixels;
    return vollathf4Value;
}

function vollathf5(image) {
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;

    tempSum1st = 0;
    tempSum2nd = 0;
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum1st += getPixel(i,j) * getPixel(i+1, j);
            tempSum2nd += getPixel(i,j);
        }
    }
    arg2 = pow(tempSum2nd, 2)/nPixels;
    vollathf5Value = (tempSum1st - arg2)/nPixels;
    return vollathf5Value;
}

function symmetricVollathf4(image){
    selectWindow(image);
    imageWidth = getWidth;
    imageHeight = getHeight;
    nPixels = imageWidth*imageHeight;

    tempSum1 = 0;
    tempSum2 = 0;
    tempSum3 = 0;
    tempSum4 = 0;
    for(i=1; i<imageWidth-1; i++) {
        for(j=1; j<imageHeight-1; j++) {
            tempSum1 += getPixel(i,j) * (getPixel(i+1, j) - getPixel(i+2, j));
            tempSum2 += getPixel(i,j) * (getPixel(i-1, j) - getPixel(i-2, j));
            tempSum3 += getPixel(i,j) * (getPixel(i, j+1) - getPixel(i, j+2));
            tempSum4 += getPixel(i,j) * (getPixel(i, j-1) - getPixel(i, j-2));
        }
    }
    symmetricVollathValue = (abs(tempSum1) + abs(tempSum2) + abs(tempSum3) + abs(tempSum4))/nPixels;
    return symmetricVollathValue;
}
