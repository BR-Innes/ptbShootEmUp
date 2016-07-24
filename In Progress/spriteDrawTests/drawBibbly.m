function drawBibbly
%% drawBibbly 
% Quick mod of Peter Scarfe's script to draw pictures. 
% Was testing whether it would draw my pixel sprites with transparency - it
% does! 
% So I made this pattern, because vanity. 
 
%~All that setup
sca;
close all;
clearvars;
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
screenColour = black; 

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, screenColour);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
ifi = Screen('GetFlipInterval', window);
[xCenter, yCenter] = RectCenter(windowRect);

Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%~ Do image display
theImage = imread('bibblyhead.tif');

% As far as I understand, s1 and s2 are height 7 width in pixels, and s3 is
% the depth... 
[s1, s2, s3] = size(theImage); 

% Looks like a useful check... 
if s1 > screenYpixels || s2 > screenYpixels
    disp('ERROR! Image is too big to fit on the screen');
    sca;
    return;
end

%~ Image (is a texture)
imageTexture = Screen('MakeTexture', window, theImage);

%~ Draw it
Screen('DrawTexture', window, imageTexture, [], [], 0);

%~ Flip 
Screen('Flip', window);

%~Wait for two seconds
WaitSecs(2);

%~ Draw it tiled 
% The last argument in is the angle (30 degrees clockwise)
Screen('DrawTexture', window, imageTexture, [], [], 30);

%~ Flip 
Screen('Flip', window);

%~Wait for two seconds
WaitSecs(2);

%~ Draw multiple ones 
% The first array is the bit of the sprite you want to draw (as a rect),
% and the second array is where you want it drawn... 

nHor = 11;
nVer = 6;

for i = 0:nHor % this script has been cursed by magic numbers
    for j = 0:nVer
    Screen('DrawTexture', window, imageTexture, [0 0 270 260], [0+(i*150) 0+(j*140) 270+(i*150) 260+(j*140)], 0);
    end 
end 

%~ Flip 
Screen('Flip', window);

%~Wait for two seconds
WaitSecs(2);

%~ Clear
sca;

end 