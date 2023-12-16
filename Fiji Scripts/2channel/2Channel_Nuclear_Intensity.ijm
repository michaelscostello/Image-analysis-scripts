// IDENTIFIES NUCLEI (C1) AND and measures intensity for C2 and C3. 
// Need to adjust particle size filter in "Analyze particles" to adjust for magnification

input = getDirectory("Source Directory"); 
list = getFileList(input); 
output = getDirectory("Output Directory");
// C1 DAPI
// C2 pERK
// C3 tERK
// C4 EGFR-GFP
setBatchMode(true)


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

        //run("Subtract Background...", "rolling=50 sliding stack");
       	run("Split Channels");
       	
  		selectWindow("C1-"+image);
  			// Processing of Image: Smooth, Make Binary, Fill holes, and watershed
  			run("Smooth");
  			run("Subtract Background...", "rolling=100 sliding stack");
  			run("Convert to Mask");
  			run("8-bit");
  			//run("Fill Holes");
			run("Watershed");
			run("Dilate");
			run("Watershed");
			// run("Erode");
  			setOption("BlackBackground", false);
  			
  			// Reports number of nuclei in Summary table (HAVE TO MANUALLY SAVE THIS!!!)
			run("Set Measurements...", "area mean modal min display redirect=None decimal=3");
			run("Analyze Particles...", "size=30-600 show=Outlines include summarize add in_situ");
			 run("Clear Results");
      
      // Nuclear pERK and tERK
       selectWindow("C2-"+image);		
       		run("Smooth");
       	 	run("From ROI Manager");
       	 	roiManager("Measure");
       selectWindow("C3-"+image);		
       	 	run("Smooth");
       		run("From ROI Manager");
       		roiManager("Measure");

       		// saveAs("Results","NUC ERKs"+image+".csv");
       			// run("Clear Results");
      
      // Dilation of C1 mask
       	// selectWindow("C1-"+image);
       		// run("Duplicate...", " "); // keeps un-dilated version to subtract
       		// roiManager("Delete");
       	// selectWindow("C1-"+image);	
       		// run("Erode");
       		
	// run("Analyze Particles...", "size=10-Infinity show=Outlines include summarize add in_situ");
	
	// Nuclear pERK and tERK  		
       		// selectWindow("C2-"+image);
       			// run("Remove Overlay");
       			// run("From ROI Manager");
       			// roiManager("Measure");
       		// selectWindow("C3-"+image);
       			// run("Remove Overlay");
       			// run("From ROI Manager");
       			// roiManager("Measure");
			
			saveAs("Results",output+image+"Nuclear Values.csv");
			run("Clear Results");
			roiManager("Delete");
       		
	   		print("Analyzed Image"+image);
}



print("MISSION ACCOMPLISHED!");
print("RESULTS ARE SAVED AS 1 FILE PER IMAGE. SUMMARY TABLE SHOWS NUMBER OF NON-DILATED AND DILATED NUCLEI");

// Use MatLab script "ERKratio_from_FIJI_ouptut" to compile all files (images) and make columns with ERK ratios