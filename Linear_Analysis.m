

% %% Linear 19.28
% linear_b = VideoReader("2024-10-14 19.28 video.mj2");
%
% %% Cross talk
%
% y_R = linear_b.ROItimeSeries(2,:,1);
% y_G = linear_b.ROItimeSeries(2,:,2);
% y_B = linear_b.ROItimeSeries(2,:,3);
%
% % Read the video file
% video = VideoReader("linear6_60fps.mp4");
%
% % Specify the pixel coordinates (replace with the pixel of interest)
% % Example: pixel at position (100, 150) in the frame
% pixel_x = 100;  % X-coordinate (column)
% pixel_y = 150;  % Y-coordinate (row)
%
% % Initialize arrays to store the RGB values for this pixel across frames
% red_values = [];
% green_values = [];
% blue_values = [];
%
% % Frame index counter
% frame_idx = 1;
% timestamps = [];
%
% % Loop through each frame of the video
% while hasFrame(video)
%     % Read the current frame
%     frame = readFrame(video);
%     timestamp = video.CurrentTime;
%     % Extract the RGB values for the specified pixel
%     red_values(frame_idx) = frame(pixel_y, pixel_x, 1);   % Red channel value
%     green_values(frame_idx) = frame(pixel_y, pixel_x, 2); % Green channel value
%     blue_values(frame_idx) = frame(pixel_y, pixel_x, 3);  % Blue channel value
%     timestamps = [timestamps;timestamp];
%     % Increment frame index
%     frame_idx = frame_idx + 1;
% end
%
% commonsize = length(y_R);
% x_orginal = linspace(1,commonsize,frame_idx-1);
% x_target = linspace(1,commonsize,commonsize);
% red_resampled = interp1(x_orginal, red_values, x_target);
% green_resampled = interp1(x_orginal, green_values, x_target);
% blue_resampled = interp1(x_orginal, blue_values, x_target);
%
% % Display the total number of frames processed
% fprintf('Total frames processed: %d\n', frame_idx-1);
%
% % Plot the RGB values for this pixel across frames
% figure;
% subplot(3,1,1);
% plot(red_values, 'r');
% title('Red Channel Values');
% xlabel('Frame');
% ylabel('Intensity');
%
% subplot(3,1,2);
% plot(green_values, 'g');
% title('Green Channel Values');
% xlabel('Frame');
% ylabel('Intensity');
%
% subplot(3,1,3);
% plot(blue_values, 'b');
% title('Blue Channel Values');
% xlabel('Frame');
% ylabel('Intensity');
%
% figure;
% plot(x_target,y_R);
% hold on;
% plot(x_target,red_resampled);
% % plot(y_G)
% % plot(y_B);
% legend("R","Red expected")
%% cross talk coeffeicient analysis
video_path_test = '2024-10-17 13.39 video.mj2';
video_path_ref = 'bars_ramp_bitDepth8_60fps.mp4';
% C_matrix =[0.986720819545330	0.452574716019242	0.129940693827568; 0.278528566065798	0.968077122093248	0.336403225954697; 0.0458944318468128	0.186583643930114	0.993993032206497];
% pixel_x = [20];
% pixel_y = [20];
pixel_x = [350,715,1200];
pixel_y = [555, 555, 555];

% tref = videoROIs2timeSeries([pixel_x(1), pixel_y(1); pixel_x(2), pixel_y(2); pixel_x(3), pixel_y(3)]);

[red_values, green_values, blue_values, timestamps_ref] = read_video_rgb(video_path_ref, pixel_x, pixel_y);
[avg_red, avg_green, avg_blue, timestamps_test] = average_rgb_block(video_path_test, pixel_x, pixel_y);


%% TESTING PLOT FOR NEW VIDEOS
% [avg_red(i,:);avg_green(i,:);avg_blue(i,:)]
Blue_C = [0.995782564877803	0.187050683312930	0.0423889555822329;
0.456669023164822	0.651571567698484	0.176187200806248;
0.131296029522920	0.226844926819069	0.997239014124168];
input =reshape(ans(1,:,:),length(ans),3)';
for i = 1:3

% plot
predicted = inv(Blue_C)*input;
figure;
hold on
plot(predicted(1,:));
plot(predicted(2,:));
plot(predicted(3,:));
% plot(input(1,:));
% plot(input(2,:));
% plot(input(3,:));
legend("R","G","B");
xlabel('Time (s)');
ylabel('Intensity');
title("Long bit transition");
% xlim([50 1300]);

end
%% 

figure;
subplot(2,1,1);
plot(timestamps_test, avg_red, 'r', 'DisplayName', 'Avg Red Block');
title('Blue Channel Comparison');
xlabel('Time (s)');
ylabel('Intensity');
subplot(2,1,2);
plot(timestamps_ref, red_values, 'r--', 'DisplayName', 'Single Red Pixel');
title('Red Channel Comparison');
xlabel('Time (s)');
ylabel('Intensity');
legend show;

figure
subplot(2,1,1);
plot(timestamps_test, avg_green, 'g', 'DisplayName', 'Avg Green Block');
xlabel('Time (s)');
ylabel('Intensity');
subplot(2,1,2);
plot(timestamps_ref, green_values, 'g--', 'DisplayName', 'Single Green Pixel');
title('Green Channel Comparison');
xlabel('Time (s)');
ylabel('Intensity');
legend show;

figure
subplot(2,1,1);
plot(timestamps_test, avg_blue, 'b', 'DisplayName', 'Avg Blue Block');
title('Blue Channel Comparison');
xlabel('Time (s)');
ylabel('Intensity');
subplot(2,1,2);
plot(timestamps_ref, blue_values, 'b--', 'DisplayName', 'Single Blue Pixel');
title('Blue Channel Comparison');
xlabel('Time (s)');
ylabel('Intensity');
legend show;
%% Green crosstalk coefficients

% Extract reference and test channel values
indices_ref = (timestamps_ref >= 0) & (timestamps_ref <= 1);
indices_test = (timestamps_test >= 0) & (timestamps_test <= 1);
index = 1;
R_segment_ref = red_values(index,indices_ref);
green_values(2:end,:) = 0;
G_segment_ref = green_values(index,indices_ref);
B_segment_ref = blue_values(index,indices_ref);

red_segment_test = avg_red(index,indices_test);
green_segment_test = avg_green(index,indices_test);
blue_segment_test = avg_blue(index,indices_test);


% Resample reference data to match the test data timeline
x_original_ref = 1:1:length(G_segment_ref);
x_target_test = linspace(1, max(x_original_ref), length(green_segment_test));
R_resampled_ref = interp1(x_original_ref, R_segment_ref, x_target_test, 'linear');
G_resampled_ref = interp1(x_original_ref, G_segment_ref, x_target_test, 'linear');
B_resampled_ref = interp1(x_original_ref, B_segment_ref, x_target_test, 'linear');

% Matrix for the linear model
X = [R_resampled_ref' G_resampled_ref' B_resampled_ref'];  % Reference data
Y = [red_segment_test' green_segment_test' blue_segment_test'];
% Gp = green_segment_test';  % Test green data
% Solve for crosstalk coefficients
C = Y' *pinv(X');

% Predict and visualize
Y_p = inv(Blue_C)* Y';

figure;
plot(X(:,index), 'g', 'DisplayName', 'Actual Green');
hold on;
plot(Y_p(:,index), 'g--', 'DisplayName', 'Predicted Green');
title('Green Channel Crosstalk Validation');
xlabel('Sample Index');
ylabel('Intensity');
legend show;

% Error calculation
mse = mean((Gp - G_predicted).^2);
disp(['Mean Squared Error for Green Channel: ', num2str(mse)]);



%% functions
function C = derive_crosstalk_matrix(RefRGB, TestRGB)
% Compute the pseudoinverse of the reference RGB matrix
RefRGB_pinv = pinv(RefRGB);
% Compute the crosstalk matrix
C = RefRGB_pinv * TestRGB;

end
% rgb for a signal pixel
function [red_values, green_values, blue_values, timestamps] = read_video_rgb(video_path, pixel_x, pixel_y)
video = VideoReader(video_path);

% Initialize arrays to store RGB values and timestamps
red_values = [];
green_values = [];
blue_values = [];
timestamps = [];

while hasFrame(video)
    frame = readFrame(video);
    red_values(1,end+1) = frame(pixel_y(1), pixel_x(1), 1);
    red_values(2,end) = frame(pixel_y(2), pixel_x(2), 1);
    red_values(3,end) = frame(pixel_y(3), pixel_x(3), 1);
    green_values(1,end+1) = frame(pixel_y(1), pixel_x(1), 2);
    green_values(2,end) = frame(pixel_y(2), pixel_x(2), 2);
    green_values(3,end) = frame(pixel_y(3), pixel_x(3), 2);
    blue_values(1,end+1) = frame(pixel_y(1), pixel_x(1), 3);
    blue_values(2,end) = frame(pixel_y(2), pixel_x(2), 3);
    blue_values(3,end) = frame(pixel_y(3), pixel_x(3), 3);
    timestamps(end+1) = video.CurrentTime;
end

end
% rgb for a block
function [avg_red, avg_green, avg_blue, timestamps] = average_rgb_block(video_path, center_x, center_y)
    % Open the video file
    video = VideoReader(video_path);

    % Calculate the size of the 20x20 block centered at the input coordinates
    half_block_size = 10;

    % Pre-allocate the arrays for RGB values and timestamps
    numFrames = floor(video.Duration * video.FrameRate);
    numPoints = length(center_x);

    avg_red = zeros(numPoints, numFrames);
    avg_green = zeros(numPoints, numFrames);
    avg_blue = zeros(numPoints, numFrames);
    timestamps = zeros(1, numFrames);

    % Read all frames once and store them
    frames = cell(1, numFrames);  % Use cell to store frames
    frameNum = 1;
    while hasFrame(video)
        frames{frameNum} = readFrame(video);
        timestamps(frameNum) = video.CurrentTime;
        frameNum = frameNum + 1;
    end

    % Loop through each (center_x, center_y) point and process each frame
    for i = 1:numPoints
        x = center_x(i);
        y = center_y(i);

        % Calculate the start and end indices for the block
        start_x = max(1, x - half_block_size);
        start_y = max(1, y - half_block_size);
        end_x = min(video.Width, x + half_block_size);
        end_y = min(video.Height, y + half_block_size);

        % Loop through each frame and calculate the average RGB values
        for frameNum = 1:numFrames
            frame = frames{frameNum};  % Get the current frame

            % Extract the block around the current center point
            block = frame(start_y:end_y, start_x:end_x, :);

            % Calculate the average RGB values for the block
            avg_red(i, frameNum) = mean(block(:, :, 1), 'all');
            avg_green(i, frameNum) = mean(block(:, :, 2), 'all');
            avg_blue(i, frameNum) = mean(block(:, :, 3), 'all');
        end
    end
end

function [red_resampled, green_resampled, blue_resampled] = interpolate_rgb(x_orginal, red_values, green_values, blue_values, x_target)
% Perform linear interpolation for RGB channels
red_resampled = interp1(x_orginal, red_values, x_target, 'linear');
green_resampled = interp1(x_orginal, green_values, x_target, 'linear');
blue_resampled = interp1(x_orginal, blue_values, x_target, 'linear');
end

