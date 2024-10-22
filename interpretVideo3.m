%function ROItimeSeries = videoROIs2timeSeries 
% Pull time-series amplitude data from video
%   videoROIs2timeSeries(filepathname) queries the user for specific
%   pixel(s) in a video to extract time-series amplitude data from. It
%   saves these data to a file and into
%   ROItimeSeries(pixelIdx,frameNum,colorChannel), an NxMx3 array
% 2024-09: Written for ESE 488, by Matthew Lew

close all;

%% parameters
debug = true;
ROIradius = 0;  % grab ROI that includes center pixel +/- ROIradius


lvl0 = 0;
lvl1 = 100;
lvl2 = 150;
lvl3 = 255;

[file,location] = uigetfile({'*.mp4';'*.mj2';'*.*'},'Open video file for analysis');
[infilepath,infilename,infileext] = fileparts([location file]);

v = VideoReader([infilepath filesep infilename  infileext]);
outfilePrefix = infilename + "_ROItimeSeries";

%% open video, ask user for ROIs

% create figure window that matches video size
figure('Position',[50 50 v.Width v.Height],"Color","black","DefaultAxesFontSize",20,"DefaultAxesXColor","white","DefaultAxesYColor","white","DefaultAxesColor","black");
axVideo = axes('position',[0 0 1 1]);
hImage = image(zeros(v.Height, v.Width, 3),"Parent",axVideo);
axis(axVideo,"image","off");
hText = text(0,0,"Frame #",...
        'color','g','FontSize',12,'VerticalAlignment','top','parent',axVideo);

% read initial frame
img = readFrame(v);

hImage.CData = img;
hText.String = "Click the center of each ROI, then press 'Return'.";
[ROIx,ROIy] = ginput;
ROIx = round(ROIx);       % round to the nearest pixel
ROIy = round(ROIy);

% mark ROI locations
hold on;
plot(ROIx,ROIy,'o');


c = [0.995782564877803	0.187050683312930	0.0423889555822329; 0.456669023164822	0.651571567698484	0.176187200806248; 0.131296029522920	0.226844926819069	0.997239014124168];


%% read remaining frames
frameNum=1;
ROItimeSeries = zeros(size(ROIx,1),v.NumFrames,3);    % ROIs x frames x 3 colors

% read video, output data files
while v.hasFrame
    % calculate ROI mean values
    for a=1:size(ROIx,1)
        ROItimeSeries(a,frameNum,:) = mean(img(ROIy(a)+(-ROIradius:ROIradius),...
                                               ROIx(a)+(-ROIradius:ROIradius),:),[1 2],"double");
    end

    if v.hasFrame  
        % read next frame
        img = readFrame(v);
        frameNum=frameNum+1;
    
        % debug: show video being read
        if debug
            hImage.CData = img;
            hText.String = "Frame " + num2str(frameNum);
            drawnow limitrate nocallbacks;
        end
    end
end

% write data
save(outfilePrefix + ".mat","ROItimeSeries","ROIx","ROIy","infilepath","infilename","infileext");

%% plot ROI intensities

timeSeries = reshape(permute(ROItimeSeries, [1, 3, 2]), 3, []);
correctedColors = inv(c) * timeSeries;

greenSignal = movmean(correctedColors(2, :), 5);
redSignal = movmean(correctedColors(1, :), 5);
blueSignal = movmean(correctedColors(3, :), 5);

close all;
figure;
plot(1:length(greenSignal), greenSignal);
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("G2");
axis tight;
figure;
plot(1:length(blueSignal), blueSignal);
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("B2");
axis tight;
figure;
plot(1:length(redSignal), redSignal);
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("R2");
axis tight;

% split green into 3 levels, 70, 90, 120, 0
greenSignal(greenSignal < 60) = lvl0;
greenSignal(greenSignal >= 60 & greenSignal <= 120) = lvl1;
greenSignal(greenSignal > 120 & greenSignal <= 220) = lvl2;
greenSignal(greenSignal > 220) = lvl3;
% [~, greenSignal] = ischange(greenSignal, "mean", "Threshold", 200);

% redSignal = ROItimeSeries(:,:, 1);
redSignal(redSignal < 60) = lvl0;
redSignal(redSignal >= 60 & redSignal <= 105) = lvl1;
redSignal(redSignal > 105 & redSignal <= 160) = lvl2;
redSignal(redSignal > 160) = lvl3;
% [~, redSignal] = ischange(redSignal, "mean", "Threshold", 200);


legendText="(" + num2str(ROIx) + "," + num2str(ROIy) + ")";
figure;
plot(ROItimeSeries(:,:,2)');
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("G values");
axis tight;

figure;
plot(1:length(greenSignal), greenSignal);
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("G values");
axis tight;

legendText="(" + num2str(ROIx) + "," + num2str(ROIy) + ")";
figure;
plot(ROItimeSeries(:,:,1)');
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("R values");
axis tight;

figure;
plot(1:length(redSignal), redSignal);
legend(legendText,"Location","best");
xlabel("Frame number");
ylabel("R values");
axis tight;
%% find bits

ne0 = find(greenSignal~=0);                                   % Nonzero Elements
ix0 = unique([ne0(1) ne0(diff([0 ne0])>1)]);        % Non-Zero Segment Start Indices
eq0 = find(greenSignal==0);                                   % Zero Elements
ix1 = unique([eq0(1) eq0(diff([0 eq0])>1)]);        % Zero Segment Start Indices
ixv = sort([ix0 ix1 length(greenSignal)]);                    % Consecutive Indices Vector

gd = diff(greenSignal);

% [pks,locs,widths,proms] = findpeaks(greenSignal);

ix0 = [];

prevDiff = -1;
for k1 = 1:length(gd)
    if (prevDiff < 0 && gd(k1) > 0)
        idx0 = [ix0, k1];
        prevDiff = gd(k1);
    end
    if (gd(k1) < 0)
        prevDiff = gd(k1);
        
    end
end

greenVals = zeros(1, length(ix0));
for k1 = 1:length(ix0)-1
    slice = greenSignal(ix0(k1):ix0(k1+1)-1);             % (Included the column)
    % slice = greenSignal(locs(k1)-widths(k1)/2:locs(k1)+widths(k1)/2);
    figure;
    plot(1:length(slice), slice);
    greenVals(k1) = mode(slice);
    disp(val)
end

ne0 = find(redSignal~=0);                                   % Nonzero Elements
ix0 = unique([ne0(1) ne0(diff([0 ne0])>1)]);        % Non-Zero Segment Start Indices
eq0 = find(redSignal==0);                                   % Zero Elements
ix1 = unique([eq0(1) eq0(diff([0 eq0])>1)]);        % Zero Segment Start Indices
ixv = sort([ix0 ix1 length(redSignal)]);                    % Consecutive Indices Vector


rd = diff(redSignal);
ix0 = [];

prevDiff = -1;
for k1 = 1:length(gd)
    if (prevDiff < 0 && gd(k1) > 0)
        idx0 = [ix0, k1];
        prevDiff = gd(k1);
    end
    if (gd(k1) < 0)
        prevDiff = gd(k1);
        
    end
end

redVals = zeros(1, length(ix0));

for k1 = 1:length(ix0)-1
    slice = redSignal(ix0(k1):ix0(k1+1)-1);             % (Included the column)
    % figure;
    % plot(1:length(slice), slice);
    redVals(k1) = mode(slice);
    % disp(val)
end

greenVals = greenVals(greenVals~=0);
redVals = redVals(redVals~=0);

idx = 1;

outputArr = zeros(1, fix(min(length(greenVals), length(redVals)) / 2));

while (idx + 1 <= min(length(greenVals), length(redVals)))
    output = 0;

    greenV = 0;

    switch(greenVals(idx))
        case lvl1
            greenV = 1;
        case lvl2
            greenV = 2;
        case lvl3
            greenV = 3;

    end

    redV = 0;
    switch(redVals(idx))
        case lvl1
            redV = 1;
        case lvl2
            redV = 2;
        case lvl3
            redV = 3;

    end
    
    greenV2 = 0;
    switch(greenVals(idx+1))
        case lvl1
            greenV2 = 1;
        case lvl2
            greenV2 = 2;
        case lvl3
            greenV2 = 3;
    end

    redV2 = 0;
    switch(redVals(idx + 1))
        case lvl1
            redV2 = 1;
        case lvl2
            redV2 = 2;
        case lvl3
            redV2 = 3;
    end

    output = bitshift(greenV2, 6) + bitshift(redV2, 4) + bitshift(greenV, 2) + redV;
    disp(output)
    outputArr(fix(idx/2)+1) = output;
    idx = idx + 1;
end

fileID = fopen('output2.bin','w');
for k = outputArr
    fwrite(fileID, k);
end
fclose(fileID);

% fileID = fopen('output.bin','w');
% 
% count = 1;
% while count + 7 <= length(bits)
%     outputs = bin2dec(strrep(num2str(bits(count:count+7)), ' ', ''));
%     fwrite(fileID, outputs);
% 
%     count = count + 8;
% end
% 
% fclose(fileID);
