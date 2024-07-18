import ij.IJ
import ij.ImagePlus
import ij.Prefs
import ij.process.FloatProcessor

//print("\\Clear")

imp = IJ.getImage()
title = imp.getTitle()
//title.print(title)
//print title
//IJ.log('title: '+title)

println add(3, 4)

//printMe()

def add(int a, int b) {
	def c = a + b
	return c
}

def printTitle(image) {
	static void getName(image) {
		something = image.getTitle();
		return something;
	};
	static void main(String[] args) {
		
	}
}
