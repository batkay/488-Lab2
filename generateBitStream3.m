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
redFrame = permute([red red red red red red red red],[3 2 1]);

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

for i = input'
    % each input is 8 bit
    numBuf = i;
    
    for j = 1:2
        % each character is interpretted and sent
        top2 = bitand(bitshift(numBuf, -2), 0x3);
        bottom2 = bitand(numBuf, 0x3);

        magG1 = 255;
        magG2 = 0;
        magG3 = 0;
        magG4 = 0;
        magG5 = 0;

        switch top2
            case 0
                % do nothing
            case 1
                magG2 = 100;
                magG3 = 100;
                magG4 = 100;
            case 2
                magG2 = 175;
                magG3 = 175;
                magG4 = 175;
            case 3
                magG2 = 255;
                magG3 = 255;
                magG4 = 255;
        end

        magR1 = 255;
        magR2 = 0;
        magR3 = 0;
        magR4 = 0;
        magR5 = 0;

        switch bottom2
            case 0
                % do nothing
            case 1
                magR2 = 100;
                magR3 = 100;
                magR4 = 100;
            case 2
                magR2 = 175;
                magR3 = 175;
                magR4 = 175;
            case 3
                magR2 = 255;
                magR3 = 255;
                magR4 = 255;
        end

        % testImg = uint8(magR1 * imresize(red, [vidHeight, vidWidth], "nearest"));
        testImg1 = uint8(magR1*imresize(redFrame,[vidHeight vidWidth],"nearest") + magG1*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg1);
        testImg2 = uint8(magR2*imresize(redFrame,[vidHeight vidWidth],"nearest") + magG2*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg2);
        testImg3 = uint8(magR3*imresize(redFrame,[vidHeight vidWidth],"nearest") + magG3*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg3);
        testImg4 = uint8(magR4*imresize(redFrame,[vidHeight vidWidth],"nearest") + magG4*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg4);
        testImg5 = uint8(magR5*imresize(redFrame,[vidHeight vidWidth],"nearest") + magG5*imresize(greenFrame,[vidHeight vidWidth],"nearest"));
        v.writeVideo(testImg5);

        disp(magG2 + " " + magR2)

        numBuf = bitshift(numBuf, -4);
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