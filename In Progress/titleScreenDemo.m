function titleScreenDemo

pixPercent = 0.0001; 
pixSpeed = 3; 

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
% scr.background = [0, 0, 0.2]; 
[scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.number, scr.background);
[scr.width, scr.height] = Screen('WindowSize', scr.window);
[scr.cenX, scr.cenY] = RectCenter(scr.windowRect);
scr.ifi = Screen('GetFlipInterval', scr.window);
scr.vbl = Screen('Flip', scr.window);
scr.waitFrames = 1;

%~Controls
ctrls.esc = KbName('ESCAPE');
ctrls.space = KbName('SPACE');
ctrls.up = KbName('UpArrow');
ctrls.down = KbName('DownArrow');
ctrls.left = KbName('LeftArrow');
ctrls.right = KbName('RightArrow'); 
ctrls.leftUp = sort([ctrls.left, ctrls.up]); 
ctrls.rightUp = sort([ctrls.right, ctrls.up]); 
ctrls.leftDown = sort([ctrls.left, ctrls.down]); 
ctrls.rightDown = sort([ctrls.right, ctrls.down]);
ctrls.movePerPress = 10; % pixels 

%~ Star Variables
stars.size = 4; 
stars.ratio = pixPercent; 
stars.movePerFrame = pixSpeed; % pixels
stars.startState = rand(scr.width, scr.height); 
stars.startPattern = stars.startState < stars.ratio; 
stars.xCs = []; 
stars.yCs = []; 
[stars.xCs, stars.yCs] = ind2sub([scr.width, scr.height], find(stars.startPattern));
stars.pattern = []; 
stars.pattern = [stars.xCs'; stars.yCs']; 
stars.angle = 30; 
stars.alpha = (stars.angle/stars.angle) * (pi/180);  


%~ Title 
txt.titleText = 'RDK DESTROYER'; 
txt.titleColour = [0.1 0.1 0.4];
txt.minorColour = [1 1 1];
txt.size = Screen('TextSize', scr.window, 30);
txt.font = Screen('TextFont', scr.window, 'Joystix');

%~ Text Setup
txt.mX = 0; 
txt.mY = 0; 
txt.minorText = ['Game & Music by Bibbly (' num2str(2016) ')'];
txt.pressStart = 'PRESS SPACE'; 

%~ Circle Setup
cir.size = [0 0 0 0];
cir.cenX = []; 
cir.cenY = []; 
cir.colour = [255, 0, 0]; 
cir.centered = []; 
cir.cenX = scr.cenX;
cir.cenY = scr.cenY;

%~ Priority set 
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%~ Find good text placement (lower right)  
[~, ~, txt.scoreBounds] = DrawFormattedText...
    (scr.window, txt.minorText, scr.width-txt.mX, scr.height-txt.mY, txt.minorColour); 
while txt.scoreBounds(3) >= scr.width || txt.scoreBounds(4) >= scr.height
    if  txt.scoreBounds(3) >= scr.width
        txt.mX = txt.mX + 10; 
    elseif txt.scoreBounds(4) >= scr.height
        txt.mY = txt.mY + 10; 
    end 
    [~, ~, txt.scoreBounds] = DrawFormattedText...
        (scr.window, txt.minorText, scr.width-txt.mX, scr.height-txt.mY, txt.minorColour); 
end 

%~ Cover up the test text 
Screen('FillRect', scr.window, scr.background, scr.windowRect);

%~ Initiate demo
exitDemo = false;
startGame = false; 
textGone = false; 
exitMain = false; 
%~ Sound Start
[y, Fs] = audioread('title.wav');
titleH = audioplayer(y, Fs);
play(titleH); 

[y2, Fs2] = audioread('theme.wav');
themeH = audioplayer(y2, Fs2);

textChange = 130; 
sizeInc = 2; 
counter = 0; 

%~ Animation loop 
while exitDemo == false
    %~ Check keys
    [~, ~, keyCode] = KbCheck;
    pressedKeys = find(keyCode); 

    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            exitDemo = true;
        elseif pressedKeys == ctrls.space 
            startGame = true; 
        end 
    end 
   
    %~ Relocate dots that have moved too high to the bottom
    stars.patternMiD = stars.pattern(2, :) <= 0;
    if isempty(stars.patternMiD) == 0 
        stars.pattern(1, stars.patternMiD) = randi(scr.width, 1, sum(stars.patternMiD)); 
        stars.pattern(2, stars.patternMiD) = scr.height; 
    end 
    
    %~ Flip
    Screen('DrawDots', scr.window, stars.pattern, stars.size, [255 255 255]);
    Screen('TextSize', scr.window, 30);
    if startGame == false
        DrawFormattedText(scr.window, txt.pressStart, 'center', (scr.height/2)+200, txt.minorColour);
        DrawFormattedText(scr.window, txt.minorText, scr.width-txt.mX, scr.height-txt.mY, txt.minorColour);
    end 
    Screen('TextSize', scr.window, textChange-counter);
    DrawFormattedText(scr.window, txt.titleText, 'center', 'center', txt.titleColour);
    if startGame == 1 
        if counter >= textChange 
            textGone = true;
            if cir.size(3) > sizeInc * 30
                stop(titleH);
                exitDemo = true; 
            else 
                cir.size(3:4) = cir.size(3:4) + sizeInc;
            end 
            cir.centered = CenterRectOnPointd(cir.size, cir.cenX, cir.cenY);
            Screen('FillOval', scr.window, txt.titleColour, cir.centered);   
        else
            counter = counter + 3; 
        end 
    end 
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    
    if textGone == true
        % rotation code here?
        stars.pattern(2, :) = stars.pattern(2, :) - stars.movePerFrame;  
    else 
        stars.pattern(2, :) = stars.pattern(2, :) - stars.movePerFrame;  
    end 
end

play(themeH);
stars.movePerFrame = pixSpeed*2; 

while startGame == true && exitMain == false; 
     %~ Check keys
    [~, ~, keyCode] = KbCheck;
    pressedKeys = find(keyCode); 

    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            exitMain = true;
        elseif pressedKeys == ctrls.left
            cir.cenX = cir.cenX - ctrls.movePerPress;
        elseif pressedKeys == ctrls.right
            cir.cenX = cir.cenX + ctrls.movePerPress;
        elseif pressedKeys == ctrls.up
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.down
            cir.cenY = cir.cenY + ctrls.movePerPress;
        end 
    elseif length(pressedKeys) == 2
        if pressedKeys == ctrls.leftUp
            cir.cenX = cir.cenX - ctrls.movePerPress;
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.leftDown
            cir.cenX = cir.cenX - ctrls.movePerPress;
            cir.cenY = cir.cenY + ctrls.movePerPress;
        elseif pressedKeys == ctrls.rightUp
            cir.cenX = cir.cenX + ctrls.movePerPress;
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.rightDown
            cir.cenX = cir.cenX + ctrls.movePerPress;
            cir.cenY = cir.cenY + ctrls.movePerPress;
        end 
    end 
    
    %~ Eccentricity checks
    if cir.cenX < 0
        cir.cenX = 0;
    elseif cir.cenX > scr.width
        cir.cenX = scr.width;
    end

    if cir.cenY < 0
        cir.cenY = 0;
    elseif cir.cenY > scr.height
        cir.cenY = scr.height;
    end
   
    %~ Relocate dots that have moved too high to the bottom
    stars.patternMiD = stars.pattern(2, :) <= 0;
    if isempty(stars.patternMiD) == 0 
        stars.pattern(1, stars.patternMiD) = randi(scr.width, 1, sum(stars.patternMiD)); 
        stars.pattern(2, stars.patternMiD) = scr.height; 
    end 
    
    %~ Flip
    Screen('DrawDots', scr.window, stars.pattern, stars.size, [255 255 255]);
    cir.centered = CenterRectOnPointd(cir.size, cir.cenX, cir.cenY);
    Screen('FillOval', scr.window, txt.titleColour, cir.centered);   
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    stars.pattern(2, :) = stars.pattern(2, :) - stars.movePerFrame;  
end 

%~ Clear
sca;
stop(titleH); 
end 
