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
vidFPS = 30;        % frame rate for video
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
blackFrame = permute([black black black black black black black black],[3 2 1]);


% reset frame
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end



for i = bitstream
    if (str2num(i) == 1)
        disp(1)

        testImg = uint8(255*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);

        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        testImg = uint8(255*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);

        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        testImg = uint8(255*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);

        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);
        
        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        
    else
        disp(0)
        testImg = uint8(255*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);

        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);

        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);
        
        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end

        testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg);
        
        if debug
            hImage.CData = testImg;
            hText.String = "Frame " + num2str(v.FrameCount);
            drawnow limitrate nocallbacks;
        end
        
    end
end

%reset
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
testImg = uint8(0*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
v.writeVideo(testImg);

if debug
    hImage.CData = testImg;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end


% close file
close(v);