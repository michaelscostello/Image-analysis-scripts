// Draw a line at the base of the cilia and record the x/y coordinates for the start and end
// Navigate to C1 and click run
// After the script has finished and you have copied the centroid values,
// close all windows and clear the ROI manager
// Navigate to C2 and click run
// Rinse and repeat

// Use the excel macro ClosestDistance() to calculate the distance from base to centroid

run("Duplicate...", "use");
run("8-bit");
run("Subtract Background...", "rolling=50 sliding stack");
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setThreshold(86, 255);
run("Convert to Mask");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Fill Holes");
run("Watershed");


setOption("ScaleConversions", true);
run("Set Measurements...", "area centroid limit display redirect=None decimal=3");
run("Analyze Particles...", "display include summarize add");
//saveAs("Results", "/Users/michaelcostello/Dropbox/aaUCSB/aaaLab/aaaFHAB/aFhaB/aaaData/01Spring_Data/Ex vivo tracheal binding/23.06.09/1147 vs 1432/20230608_131651_486/Results.csv");
//roiManager("Select All");
//roiManager("Delete");
