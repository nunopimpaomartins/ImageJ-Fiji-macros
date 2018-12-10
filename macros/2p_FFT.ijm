title = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);

setBatchMode(true);
for(i=1;i<=slices;i++) {
	selectWindow(title);
	setSlice(i);
	wait(50);
	run("FFT");
	selectWindow("FFT of "+title);
	rename("Corrected fft slice "+i);
	run("Specify...", "width="+width/4+" height="+height/4+" x="+width/2+" y="+height/2+" oval centered");
	run("Make Inverse");
	run("Find Maxima...", "noise=20 output=[Point Selection]");
	run("Enlarge...", "enlarge=3 pixel");
	run("Clear");
	run("Inverse FFT");
	selectWindow("Corrected fft slice "+i);
	close();
};
run("Images to Stack", "name=[Corrected_"+title+"] title=[Inverse FFT of Corrected fft slice]");
setBatchMode(false);
