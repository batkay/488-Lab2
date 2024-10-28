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

dimensions = 22;
gridSize = (dimensions-1);

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

frame = zeros(dimensions, dimensions, 3);

% reset frame
frame(1, 1, :) = 255 * green;
frame(1, dimensions, :) = 255 * green;
frame(dimensions, 1, :) = 255 * green;

frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);

if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

frame(1, 1, :) = 255 * green;
frame(1, dimensions, :) = 255 * green;
frame(dimensions, 1, :) = 255 * green;

frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
frame(1, 1, :) = 255 * green;
frame(1, dimensions, :) = 255 * green;
frame(dimensions, 1, :) = 255 * green;

frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
frame(1, 1, :) = 255 * green;
frame(1, dimensions, :) = 255 * green;
frame(dimensions, 1, :) = 255 * green;

frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

pixel = 1;
clk = 0;

for i = input'
    % each input is 8 bit
    numBuf = i;
    
    for j = 1:4
        % each character is interpretted and sent
        top2 = bitand(bitshift(numBuf, -1), 0x1);
        bottom2 = bitand(numBuf, 0x1);


        % pixel mod 16 + 2, pixel
        frame(floor((pixel-1)/gridSize) + 2, mod(pixel-1, gridSize) + 2, :) = (double(255 * bottom2) * red) + (double(255 * top2) * green);

        % disp(magG2 + " " + magR2)
        
        if (pixel == gridSize*gridSize)
            pixel = 1;

            clkPixel = black;
            if (clk)
                clkPixel = green;
            end


            frame(1, 1, :) = 255 * clkPixel;
            frame(1, dimensions, :) = 255 * clkPixel;
            frame(dimensions, 1, :) = 255 * clkPixel;


            frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
            v.writeVideo(frameResize);
            if debug
                hImage.CData = frame;
                hText.String = "Frame " + num2str(v.FrameCount);
                drawnow limitrate nocallbacks;
            end
            frame = zeros(dimensions, dimensions, 3);

            clk = ~clk;
        else
            pixel = pixel + 1;
        end

        numBuf = bitshift(numBuf, -2);
    end

    

end


if (pixel ~= 1)
    pixel = 1;

    clkPixel = black;
    if (clk)
        clkPixel = green;
    end


    frame(1, 1, :) = 255 * clkPixel;
    frame(1, dimensions, :) = 255 * clkPixel;
    frame(dimensions, 1, :) = 255 * clkPixel;

    frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
    v.writeVideo(frameResize);
    frame = zeros(dimensions, dimensions, 3);

    clk = ~clk;

end

clkPixel = black;
if (clk)
    clkPixel = green;
end

%reset
frame(1, 1, :) = 255 * clkPixel;
frame(1, dimensions, :) = 255 * clkPixel;
frame(dimensions, 1, :) = 255 * clkPixel;

frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

frame(1, 1, :) = 255 * clkPixel;
frame(1, dimensions, :) = 255 * clkPixel;
frame(dimensions, 1, :) = 255 * clkPixel;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end
frame(1, 1, :) = 255 * clkPixel;
frame(1, dimensions, :) = 255 * clkPixel;
frame(dimensions, 1, :) = 255 * clkPixel;
frameResize = uint8(imresize(frame,[vidHeight vidWidth],"nearest"));
v.writeVideo(frameResize);
if debug
    hImage.CData = frame;
    hText.String = "Frame " + num2str(v.FrameCount);
    drawnow limitrate nocallbacks;
end

% close file
close(v);