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
       	
       	selectWindow("C1-" + image);
       	setMinAndMax(1400,2400);
       	rename("C1");
       	
       	selectWindow("C2-" + image);
       	setMinAndMax(1400,2400);
       	rename("C2");
       	
       	selectWindow("C3-" + image);
       	setMinAndMax(5000,20000);
       	rename("C3");
       	
       	run("Merge Channels...", "c1=[C1] c2=[C2] c3=[C3] create");
       	run("RGB Color", "slices");
       	run("AVI... ", "compression=JPEG frame=7");
       	saveAs("avi");
       	
       	close("*");
}