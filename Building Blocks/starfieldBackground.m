function starfieldBackground(pixPercent, pixSpeed)

if exist('pixPercent', 'var') == 0
    pixPercent = 0.0001; 
end 

if exist('pixSpeed', 'var') == 0
    pixSpeed = 3; 
end 

%~ Clear the workspace and the screen
sca;
close all;
myGraphicsTimingSucksMode = true; 

%~ Skip sync if using laptop (graphics card issues) 
if myGraphicsTimingSucksMode
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference','SuppressAllWarnings', 1);
    Screen('Preference','VisualDebugLevel', 0); 
end 

%~ Screen Variables 
scr.background = []; 
scr.foreground = []; 
scr.window = []; 
scr.windowRect = []; 
scr.height = []; 
scr.width = []; 
scr.cenX = []; 
scr.cenY = [];
scr.ifi = []; 
scr.vbl = []; 
scr.waitFrames = [];
scr.exit = false; 

%~ Setup screen 
PsychDefaultSetup(2);
screens = Screen('Screens');
scr.number = max(screens);
scr.foreground = WhiteIndex(scr.number);
scr.background = BlackIndex(scr.number);
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.number, scr.background);
[scr.width, scr.height] = Screen('WindowSize', scr.window);
[scr.cenX, scr.cenY] = RectCenter(scr.windowRect);
scr.ifi = Screen('GetFlipInterval', scr.window);
scr.vbl = Screen('Flip', scr.window);
scr.waitFrames = 1;

%~Controls
ctrls.esc = KbName('ESCAPE');

%~ Star Variables
stars.ratio = pixPercent; 
stars.movePerFrame = pixSpeed; % pixels
stars.startState = rand(scr.width, scr.height); 
stars.startPattern = stars.startState < stars.ratio; 
stars.xCs = []; 
stars.yCs = []; 
[stars.xCs, stars.yCs] = ind2sub([scr.width, scr.height], find(stars.startPattern));
stars.pattern = []; 
stars.pattern = [stars.xCs'; stars.yCs']; 

%~ Priority 
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);

%~ Initiate demo
exitDemo = false;

%~ Animation loop 
while exitDemo == false
   
    %~ Check keys
    [~, ~, keyCode] = KbCheck;
    pressedKeys = find(keyCode); 

    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            exitDemo = true;
        end 
    end 
   
    %~ Relocate dots that have moved too high to the bottom
    stars.patternMiD = stars.pattern(2, :) <= 0;
    if isempty(stars.patternMiD) == 0 
        stars.pattern(1, stars.patternMiD) = randi(scr.width, 1, sum(stars.patternMiD)); 
        stars.pattern(2, stars.patternMiD) = scr.height; 
    end 
    
    %~ Flip
    Screen('DrawDots', scr.window, stars.pattern, 1, [255 255 255]);
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    stars.pattern(2, :) = stars.pattern(2, :) - stars.movePerFrame;
    
end

%~ Clear
sca;
end 
