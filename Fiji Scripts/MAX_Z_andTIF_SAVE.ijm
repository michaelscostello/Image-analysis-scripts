// Create Z projection and then count number of nuclei in C1 and take total fluoresence of C2
// Using to quantify total pEGFR signal normalized to number of nuclei

input = getDirectory("Source Directory"); 
list = getFileList(input); 
output = getDirectory("Output Directory");

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
        
       	run("Z Project...", "projection=[Max Intensity]");
   saveAs("tiff",output+image); 
}



print("MISSION ACCOMPLISHED!");

