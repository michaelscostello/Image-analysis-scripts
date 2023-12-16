clear 
close 
clc

% Path to the CSV files, exported from TrackMate.
spots_csv_file = '/Users/michaelcostello/Dropbox/aaUCSB/aaaLab/aaaFHAB/aFhaB/aaaData/01Spring_Data/Ex vivo tracheal binding/22.10.26 Rat/1155.1141/Movies/20221026_183040_411/Trackmate_3/mutant_spot_1.csv'; 
edges_csv_file = '/Users/michaelcostello/Dropbox/aaUCSB/aaaLab/aaaFHAB/aFhaB/aaaData/01Spring_Data/Ex vivo tracheal binding/22.10.26 Rat/1155.1141/Movies/20221026_183040_411/Trackmate_3/mutant_edge_1.csv';

%% Load CSV files into MATLAB tables.
%spot_table = readtable( spots_csv_file ); 
edge_table = readtable( edges_csv_file );


%% Display info on tables.
%fprintf( 'Header of the spot table:\n' ) 
%head( spot_table )

fprintf( '\nHeader of the edge table:\n' ) 
head( edge_table )

ma = msdanalyzer(2, LABEL, EDGE_TIME);
ma = ma.addAll(tracks);

V = vertcat( v{:} );

hist(V(:, 2:end), 50) % we don't want to include the time in the histogram
box off
xlabel([ 'Velocity (' SPACE_UNITS '/' TIME_UNITS ')' ])
ylabel('#')
