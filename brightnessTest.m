% generateBarRampVideo
%   write video containing a series of colored bars with decreasing
%   brightness over time
%   The output size, frames per second, and bit depth of the ramp are
%   adjustable.
% 2024-09: Written for ESE 488, by Matthew Lew

clearvars;
close all;

debug = true;

%% transmission parameters
% size of output video
vidWidth = 1440;
vidHeight = 1080;   
vidFPS = 60;        % frame rate for video
bitDepth = 6;

outfile = "brightness" + num2str(bitDepth) + "_" + num2str(vidFPS) + "fps";

%% output data to video
% v = VideoWriter(outfile,"Archival");  % lossless compressed format
v = VideoWriter(outfile,"MPEG-4");
v.Quality = 98; % quality level only applies to MPEG-4 videos
v.FrameRate = vidFPS;
open(v);

% debug: show video being written
if debug
    figure('Position',[50 50 vidWidth vidHeight],"Color","black","DefaultAxesFontSize",20,"DefaultAxesXColor","white","DefaultAxesYColor","white","DefaultAxesColor","black");
    axVideo = axes('position',[0 0 1 1]);
    hImage = image(zeros(vidHeight, vidWidth, 3),"Parent",axVideo);
    axis(axVideo,"image","off");
    hText = text(0,0,"Frame #",...
            'color','g','FontSize',14,'VerticalAlignment','top','parent',axVideo);
end



% define colors
green = [0; 1; 0];
red = [1; 0; 0];
blue = [0; 0; 1];
black = [0; 0; 0];
magenta = red+blue;
yellow = red+green;
cyan = green+blue;
white = red+green+blue;

greenFrame = permute([green green green green green green green green],[3 2 1]);


for i = 1:255
    
    testImg = uint8(round(i/36)*36*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
    v.writeVideo(testImg);
    
    if debug
        hImage.CData = testImg;
        hText.String = "Frame " + num2str(v.FrameCount);
        drawnow limitrate nocallbacks;
    end
end

% close file
close(v);