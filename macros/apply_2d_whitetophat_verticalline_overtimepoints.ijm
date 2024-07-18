title = getTitle();

Stack.getDimensions(width, height, channels, slices, frames);
//print(frames);
setBatchMode(true);
for(i=1; i<=frames; i++){
	selectWindow(title);
	Stack.setFrame(i);
	run("Morphological Filters", "operation=[White Top Hat] element=[Vertical Line] radius=2");
	if(i==1){
		rename("stack_line_filter");	
	} else {
		rename("time_step");
	};
	if(i>1){
		run("Concatenate...", "  title=stack_line_filter image1=stack_line_filter image2=time_step image3=[-- None --]");
	};
};
setBatchMode("exit and display");