function drawGang
 
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
Ben = imread('Ben.tif');
Bibbly = imread('Bibbly.tif');
Jibbly = imread('Jibbly.tif'); 

%~ Image (is a texture)
BenTexture = Screen('MakeTexture', window, Ben);
Screen('DrawTexture', window, BenTexture, [], [], 0);
Screen('Flip', window);

WaitSecs(2); 

for i = 1:6
    
screenColour = [1, 0, 0]; 
Screen('FillRect', window, screenColour, windowRect);
%~ Draw it
Screen('DrawTexture', window, BenTexture, [], [], -40);
 
%~ Flip 
Screen('Flip', window);

%~Wait 
WaitSecs(0.2);

screenColour = [0.8, 0.2, 0.2]; 
Screen('FillRect', window, screenColour, windowRect);

%~ Draw it
Screen('DrawTexture', window, BenTexture, [], [], 40);

%~ Flip 
Screen('Flip', window);

%~Wait for two seconds
WaitSecs(0.2);
end 
%~ Clear
sca;

end 