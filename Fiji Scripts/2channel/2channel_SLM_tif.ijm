input = getDirectory("Source Directory"); 
list = getFileList(input); 
output = getDirectory("Output Directory");
setBatchMode(true)

// C2 RB50
// C2 Cilia

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

  
       	
       	run("Merge Channels...");
       	saveAs("tiff, dir+title");
       	close("*");
}
       	