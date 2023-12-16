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

  		run("8-bit");
       	run("Split Channels");
       	
       	
		selectWindow("C1-" + image);
			run("3D Fast Filters","filter=Median radius_x_pix=1.0 radius_y_pix=1.0 radius_z_pix=1.0 Nb_cpus=12");
			selectWindow("3D_Median");
			run("3D Simple Segmentation", "low_threshold=50 min_size=10 max_size=-1");
			close("3D_Median");
			//saveAs("tiff, output+image+488seg.tif");
			run("3D Manager");
			Ext.Manager3D_AddImage();
			Ext.Manager3D_SelectAll();
			Ext.Manager3D_Measure();
			Ext.Manager3D_SaveResult("M", output+image+"488.csv");
			Ext.Manager3D_CloseResult("M");
			Ext.Manager3D_Delete();
			Ext.Manager3D_Close();
			close("Seg");
			print("done C1");
			
	
			selectWindow("C2-" + image);
			run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus=12");
			selectWindow("3D_Median");
			run("3D Simple Segmentation", "low_threshold=50 min_size=10 max_size=-1");
			//saveAs("tiff, output+image+568seg.tif");
			close("3D_Median");
			run("3D Manager");
			Ext.Manager3D_AddImage();
			Ext.Manager3D_SelectAll();
			Ext.Manager3D_Measure();
			Ext.Manager3D_SaveResult("M", output+image+"568.csv");
			Ext.Manager3D_CloseResult("M");
			Ext.Manager3D_Delete();
			Ext.Manager3D_Close();
			close("Seg");
			print("done C2");
			close("*");

}
			
			
			
			
			
print("all done");
close("*");