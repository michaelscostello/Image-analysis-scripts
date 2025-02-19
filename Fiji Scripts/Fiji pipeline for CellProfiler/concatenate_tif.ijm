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

  	run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack open_all_series concatenate_series stack_order=XYCZT series_");

	rename("image");

	run("Split Channels");

  selectWindow("C1-" + image);
       	setMinAndMax(400,1500);
       	rename("C1");
       	
       	selectWindow("C2-" + image);
       	setMinAndMax(450,2000);
       	rename("C2");
       	
       	selectWindow("C3-" + image);
       	setMinAndMax(6000,65535);
       	rename("C3");
       	
       	run("Merge Channels...", "create");
       	
    	saveAs("tiff, dir+title");
       	close("*");
       	
     
}