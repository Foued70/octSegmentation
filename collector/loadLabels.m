function interpolation = loadLabels(filename,options)
% loadLabels - loads labels (i.e. ground truth of OCT-scans) with the respective routine defined in options.loadRoutineLabels
% 
% Inputs:
%   filename - [string] filename => the name of the matfile holding the data with an additional _option.labelID_coordinates
%   options  - [struct] collector options struct
%     .folder_labels     - [string] points to the folder of [filename '_' options.labelID_coordinates]
%     .labelID           - [int] Spectralis B-Scans are labeled B0,B1,..., for each ID there exists a mat-file with labels
%     .clip              - [boolean] indicates whether to clip a B-Scan at the left and right border
%     .clipRange         - [array](2) defines the left and right border of the B-Scan after clipping 
%     .verbose           - [int] level of verbosity
%     .loadRoutineLabels - [string] the user-defined routine that is used to load the labels
%
% Outputs:
%   interpolation - [matrix] the segmented boundaries for the respective scan
%
% See also: loadData, fetchPatches, collectTrnData, collectTestData

% Author: Fabian Rathke
% email: frathke@googlemail.com
% Website: https://github.com/FabianRathke/octSegmentation
% Last Revision: 18-Dec-2013

% strip '*.mat' from filename
filename = strrep(filename,'.mat','');

if strcmp(options.loadRoutineLabels,'LabelsFromLabelingTool')
	load([options.folder_labels filename '_' num2str(options.labelID-1) '_coordinates.mat']);
elseif strcmp(options.loadRoutineLabels,'spectralisLabels')
	load([options.folder_labels filename],sprintf('B%dseg',options.labelID-1));
	eval(sprintf('interpolation = B%dseg',options.labelID));
	interpolation(interpolation > options.Y) = 100;
elseif strcmp(options.loadRoutineLabels,'AMDDataset')
	load([options.folder_labels filename '_' num2str(options.labelID) '_coordinates.mat']);
	interpolation = [zeros(size(interpolation,1),200) interpolation zeros(size(interpolation,1),200)];
else
	error('Please specify a valid routine for loading labels in collector.options.loadRoutineLabels');
end
printMessage(sprintf('Loaded labels for %s and region %d.\n',filename,options.labelID),2,options.verbose);

if options.clip
	interpolation = interpolation(:,options.clipRange(1):options.clipRange(2));
end

end

