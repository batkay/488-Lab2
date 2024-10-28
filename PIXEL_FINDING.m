%% Pixel Determination

video = VideoReader('488-Lab2\2024-10-28 00.11 video.mj2');
numFrames = floor(video.Duration * video.FrameRate);
frames = cell(1, numFrames);  % Use cell to store frames
frameNum = 1;
while hasFrame(video)
    frames{frameNum} = readFrame(video);
    frameNum = frameNum + 1;
end

%%
rgb= frames{1};
clock_loc = rgb;
clock_loc_G = clock_loc(:,:,2);
clock_loc_R = clock_loc(:,:,1);

mask = imbinarize(clock_loc_G-clock_loc_R);
filled= imfill(mask,"holes");
% figure;
% imshow(clock_loc);
% figure;
% imshow(mask);
figure;
imshow(filled);
hold on;
corners = detectMSERFeatures(filled);
x = corners.Location(:,1);
y = corners.Location(:,2);

% plot(corners)
% plot(corners.Location(:,1),corners.Location(:,2),'LineWidth',4);
% 
% pixel_loc_x = linspace(min(x),max(x),21);
% pixel_loc_y = linspace(min(y),max(y),21);
% [X, Y] = meshgrid(pixel_loc_x, pixel_loc_y);
% hold off;
% 
% figure;
% imshow(frames{100});


%% 
% Load the image
image = frames{1};
imshow(image);
title('Select 4 points in order: top-left, top-right, bottom-left, bottom-right');

movingPoints = corners.Location;

% Define corresponding ideal points for a straight rectangular shape
fixedPoints = [
    0, 0;            % top-left
    size(image, 2), 0; % top-right
    0, size(image, 1); % bottom-left
    size(image, 2), size(image, 1) % bottom-right
];

% Fit projective transformation
tform = fitgeotform2d(movingPoints, fixedPoints, 'projective');

% Apply transformation to correct the image
outputImage = imwarp(image, tform);

% Display the corrected image
figure;
imshow(outputImage);
hold on;
title('Corrected Image with Projective Transformation');

%% 
new_corners = detectMSERFeatures(imbinarize(outputImage(:,:,2)));
new_x= new_corners.Location(:,1);
new_y = new_corners.Location(:,2);

% % figure;
% plot(new_x,new_y,'LineWidth',4);

pixel_loc_x = linspace(min(new_x),max(new_x),23);
pixel_loc_y = linspace(min(new_y),max(new_y),23);
[new_X, new_Y] = meshgrid(pixel_loc_x(2:end-1), pixel_loc_y(2:end-1));

outputImage_100 = imwarp(frames{200}, tform);
figure;
imshow(outputImage_100);
hold on;
scatter(new_X,new_Y);
title('Corrected Image with Projective Transformation');


%% extracting the rgb values from the video
r = [];
g = [];
b = [];
clock = [];
X= round(X);
Y = round(Y);
clock_x=round(new_x(1));
clock_y=round(new_y(1));
for i = 1:1:frameNum-1
    frame = frames{i};
    outputImage = imwarp(frame, tform);
    [avg_red, avg_green, avg_blue, avg_green_clock] = average_rgb_block_per_frame(outputImage, X, Y, clock_x, clock_y);
    r = cat(3, r, avg_red);
    g = cat(3, g, avg_green);
    b = cat(3, b, avg_blue);
    clock = [clock, avg_green_clock];
end
%% 

figure;
plot(squeeze(r(2, 1, :)), 'r'); % Extract and plot the red channel for point (1,1) across frames
hold on;
plot(squeeze(g(2, 1, :)), 'g'); % Extract and plot the green channel for point (1,1) across frames
plot(squeeze(b(2, 1, :)), 'b'); % Extract and plot the blue channel for point (1,1) across frames
plot(clock);

legend("r", "g", "b","Clock");
xlabel('Frame Number');
ylabel('Average RGB Value');
title('RGB Values Over Time for Point (1,1)');

%% 

save('average_rgb_values.mat', 'r', 'g', 'b', 'clock');

%% 

function [avg_red, avg_green, avg_blue, avg_green_clock] = average_rgb_block_per_frame(frame, center_x, center_y, clock_x, clock_y)
    half_block_size = 3;
    [numRows, numCols] = size(center_x);

    avg_red = zeros(numRows, numCols);
    avg_green = zeros(numRows, numCols);
    avg_blue = zeros(numRows, numCols);
    avg_green_clock = zeros(1, 1);

    % For each point, calculate the average RGB within the block
    for row = 1:numRows
        for col = 1:numCols
            x = center_x(row, col);
            y = center_y(row, col);

            % Calculate the start and end indices for the block
            start_x = max(1, x - half_block_size);
            start_y = max(1, y - half_block_size);
            end_x = min(size(frame, 2), x + half_block_size);
            end_y = min(size(frame, 1), y + half_block_size);

            % Extract the block and calculate the average RGB values
            block = frame(start_y:end_y, start_x:end_x, :);
            avg_red(row, col) = mean(block(:, :, 1), 'all');
            avg_green(row, col) = mean(block(:, :, 2), 'all');
            avg_blue(row, col) = mean(block(:, :, 3), 'all');
        end
    end

    % Calculate the average green channel for the clock location
    start_x_clock = max(1, clock_x - half_block_size);
    start_y_clock = max(1, clock_y - half_block_size);
    end_x_clock = min(size(frame, 2), clock_x + half_block_size);
    end_y_clock = min(size(frame, 1), clock_y + half_block_size);

    clock_block = frame(start_y_clock:end_y_clock, start_x_clock:end_x_clock, :);
    avg_green_clock = mean(clock_block(:, :, 2), 'all');
end
