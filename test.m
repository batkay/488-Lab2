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

outfile = "stream_bitDepth" + num2str(bitDepth) + "_" + num2str(vidFPS) + "fps";

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

bitstream = [1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0];

fileID = fopen("bits.bin");
input = fread(fileID);
bitstream = dec2bin(input, 8);
bitstream = reshape(bitstream', 1, []);
fclose(fileID);

% bitstream = [bitstream, zeros(1, mod(length(bitstream), 16))];

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

frame = zeros(17, 17, 3);

% reset frame
frame(1, 1, :) = green;
frame(1, 17, :) = green;
frame(17, 1, :) = green;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);

if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

frame(1, 1, :) = green;
frame(1, 17, :) = green;
frame(17, 1, :) = green;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
frame(1, 1, :) = green;
frame(1, 17, :) = green;
frame(17, 1, :) = green;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
frame(1, 1, :) = green;
frame(1, 17, :) = green;
frame(17, 1, :) = green;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

clkPixel = green;
%reset
frame(1, 1, :) = clkPixel;
frame(1, 17, :) = clkPixel;
frame(17, 1, :) = clkPixel;
frame(8, 8, :) = clkPixel;

frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

frame(1, 1, :) = clkPixel;
frame(1, 17, :) = clkPixel;
frame(17, 1, :) = clkPixel;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
frame(1, 1, :) = clkPixel;
frame(1, 17, :) = clkPixel;
frame(17, 1, :) = clkPixel;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

% close file
close(v);