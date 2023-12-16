input = getDirectory("Source Directory"); 
list = getFileList(input); 
output = getDirectory("Output Directory");
setBatchMode(true)

// C1 Mutant
// C2 WT

for (i=0; i<list.length; i++) 
{
    image = list[i];
    path = input + image;
    dotIndex = indexOf(image, ".");
    title = substring(image, 0, dotIndex);
    run("Bio-Formats Macro Extensions");
    Ext.setId(path);
    Ext.getCurrentFile(file);
    Ext.getSeriesCount(seriesCount);
    Ext.getSizeZ(sizeZ);

  	run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_");

  
       	run("Split Channels");
			selectWindow("C3-" +image);
			run("Smooth", "stack");
  			run("Subtract Background...", "rolling=100 sliding stack");
			
			for (i=1; i<=nSlices; i++) {
				setSlice(i);
				if (i>=1) {
					run("Convert to Mask", "method=Default background=Dark calculate black create");
					run("Create Selection");
				}
			
				roiManager("add");	
			}
			
		selectWindow("C1-" +image);
			for (i=0; i<nSlices; i++) {
				selectWindow("C1-" +image);
				run("From ROI Manager");
				roiManager("select", i);
				run("Clear Outside", "slice");
			}
			
		selectWindow("C2-" +image);
		for (i=0; i<nSlices; i++) {
				selectWindow("C2-" +image);
				run("From ROI Manager");
				roiManager("select", i);
				run("Clear Outside", "slice");
			}
			
			setBatchMode("exit and display");
		
		selectWindow("C1-" +image);
			saveAs("tiff", output+image+"C1.tif");
			rename("C1");
			//close("C1-" +image);
		
		selectWindow("C2-" +image);
			saveAs("tiff", output+image+"C2.tif");
			//close("C2-" +image);
			rename("C2");
			
			run("Merge Channels...", "c1=[C1] c2=[C2] create keep");
			saveAs("tiff", output+image+"merge.tif");
			
}

 macro "Close All Windows" { 
      while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
  } 
			
