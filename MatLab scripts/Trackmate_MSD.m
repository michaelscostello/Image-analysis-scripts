clear 
close 
clc

%Import trackmate xml files, remove z, and correct for time 
[tracks, md] = importTrackMateTracks('/Users/michaelcostello/Dropbox/aaUCSB/aaaLab/aaaFHAB/aFhaB/aaaData/01Spring_Data/Ex vivo tracheal binding/22.10.26 Rat/1155.1141/Movies/20221026_183040_411/Trackmate_3/mutant_revised.xml', 'clipz', 'scalet'); 


% Get velocities and concatenate all tracks
ma = msdanalyzer(2, 'spaceUnits', 'timeUnits');
ma = ma.addAll(tracks);
v = ma.getVelocities; 

V = vertcat( v{:} );


%Plot velocities on histogram
hist(V(:, 2:end), 50) % we don't want to include the time in the histogram
box off
xlabel([ 'Velocity (spaceUnits/timeUNITS)' ])
ylabel('#')

%Plot tracks in XY
%ma.plotTracks;
%ma.labelPlotTracks;