clear 
close 
clc


[tracks, md] = importTrackMateTracks('/Users/michaelcostello/Dropbox/aaUCSB/aaaLab/aaaFHAB/aFhaB/aaaData/01Spring_Data/Ex vivo tracheal binding/22.10.26 Rat/1155.1141/Movies/20221026_183040_411/Trackmate_3/mutant.xml', 'clipz', 'scalet'); 

tracks

md

ma = msdanalyzer(2, 'spaceUnits', 'timeUnits');
ma = ma.addAll(tracks);
v = ma.getVelocities; 

V = vertcat( v{:} );

hist(V(:, 2:end), 50) % we don't want to include the time in the histogram
box off
xlabel([ 'Velocity (spaceUnits/timeUNITS)' ])
ylabel('#')

ma.plotTracks;
ma.labelPlotTracks;