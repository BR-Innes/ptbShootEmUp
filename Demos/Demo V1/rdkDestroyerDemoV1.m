function rdkDestroyerDemoV1
%% rdkDemoV1
% "I bet he's never written a parallax sprite starfield sine scrolly 
% bob demo with soundtracker music in his life" 
% ------------------------------------------------------------------
% A Fudgy Demo 
% Written by Bibbly x (24/07/16)
% 
% CONTROLS
% Move: Arrow Keys
% Fire: Space
% Quit: Escape
%-------------------------------------------------------------------

%~ Clear the workspace and the screen
sca;
close all;

%~ Skip sync if using laptop (graphics card issues) 
myGraphicsTimingSucksMode = true; 

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

%~ Controls
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
stars.ratio = 0.0001; 
stars.movePerFrame = 3; % pixels
stars.startState = rand(scr.width, scr.height); 
stars.startPattern = stars.startState < stars.ratio; 
stars.xCs = []; 
stars.yCs = []; 
[stars.xCs, stars.yCs] = ind2sub([scr.width, scr.height], find(stars.startPattern));
stars.pattern = []; 
stars.pattern = [stars.xCs'; stars.yCs'];  
stars.colour = [1, 1, 1]; 

%~ Text
txt.font = Screen('TextFont', scr.window, 'Joystix');
% Title
txt.titleText = 'RDK DESTROYER'; 
txt.titleColour = [0.1 0.1 0.4];
txt.titleSize = 130;
txt.titleShrinkIncrement = 2; 
% Credit
txt.creditText = ['Game & Music by Bibbly (' num2str(2016) ')'];
txt.creditSize = 30; 
txt.creditX = 0; 
txt.creditY = 0;
txt.creditColour = [1 1 1];
% Press Space
txt.pressSpace = 'PRESS SPACE'; 
txt.pressSpaceSize = 30;
txt.pressSpaceColour = [1 1 1];
txt.pressSpaceY = scr.cenY + 200; 
% Thanks 
txt.thanks = 'THANKS FOR PLAYING!'; 
txt.thanksSize = 80;
txt.thanksColour = [0.1 0.1 0.4];  

%~ Circle Setup
cir.size = [0, 0, 0, 0];
cir.cenX = []; 
cir.cenY = []; 
cir.colour = [0.1 0.1 0.4]; 
cir.centered = []; 
cir.cenX = scr.cenX;
cir.cenY = scr.cenY;
cir.growIncrement = 2;
cir.maxSize = 40; 

%~Bullets
bullets.XY = []; 
bullets.refractory = 10; 
bullets.refractoryC = 10; 
bullets.movePerFrame = 10; 
bullets.colour = [255, 0, 0]; 
bullets.size = 7; 

%~ Demo Times
demoT.themeLength = 68;
demoT.titleLength = 232; 
demoT.blank = 1; 
demoT.showThanks = 2; 
demoT.all = demoT.blank*2 + demoT.showThanks;

%~ Read in .wav files
[yTitle, FsTitle] = audioread('title.wav');
titleH = audioplayer(yTitle, FsTitle);

[yTheme, FsTheme] = audioread('theme.wav');
themeH = audioplayer(yTheme, FsTheme);

%~ Priority set 
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%~ Find good text placement (lower right)  
Screen('TextSize', scr.window, txt.creditSize);
[~, ~, txt.scoreBounds] = DrawFormattedText...
    (scr.window, txt.creditText, scr.width-txt.creditX, scr.height-txt.creditY, txt.creditColour); 
while txt.scoreBounds(3) >= scr.width || txt.scoreBounds(4) >= scr.height
    if  txt.scoreBounds(3) >= scr.width
        txt.creditX = txt.creditX + 10; 
    elseif txt.scoreBounds(4) >= scr.height
        txt.creditY = txt.creditY + 10; 
    end 
    [~, ~, txt.scoreBounds] = DrawFormattedText...
        (scr.window, txt.creditText, scr.width-txt.creditX, scr.height-txt.creditY, txt.creditColour); 
end 

%~ Cover up the test text 
Screen('FillRect', scr.window, scr.background, scr.windowRect);

%~ Flags
exitDemo = false;
startGame = false;  
exitMain = false;

%~ Counters
counterAfterPress = 0; 
counterIncrement = 3; 

%~ Play title theme
play(titleH); 

%~ TITLE: Animation loop 
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
    Screen('DrawDots', scr.window, stars.pattern, stars.size, stars.colour);
    if startGame == false
        Screen('TextSize', scr.window, txt.pressSpaceSize);
        DrawFormattedText(scr.window, txt.pressSpace, 'center', txt.pressSpaceY, txt.creditColour);
        Screen('TextSize', scr.window, txt.creditSize);
        DrawFormattedText(scr.window, txt.creditText, scr.width-txt.creditX, scr.height-txt.creditY, txt.creditColour);
    end 
    Screen('TextSize', scr.window, txt.titleSize-counterAfterPress);
    DrawFormattedText(scr.window, txt.titleText, 'center', 'center', txt.titleColour);
    if startGame == 1 
        if counterAfterPress >= txt.titleSize
            if cir.size(3) > cir.growIncrement * cir.maxSize
                stop(titleH);
                exitDemo = true; 
            else 
                cir.size(3:4) = cir.size(3:4) + txt.titleShrinkIncrement;
            end 
            cir.centered = CenterRectOnPointd(cir.size, cir.cenX, cir.cenY);
            Screen('FillOval', scr.window, cir.colour, cir.centered);   
        else
            counterAfterPress = counterAfterPress + counterIncrement; 
        end 
    end 
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    stars.pattern(2, :) = stars.pattern(2, :) - stars.movePerFrame; 
    
end

%~ Change music and make stars go fast
play(themeH);
stars.movePerFrame = stars.movePerFrame*2; 
timeGameDemoStart = GetSecs; 

%~ GAME: Animation loop 
while startGame == true && exitMain == false; 
     %~ Check keys
    [~, ~, keyCode] = KbCheck;
    pressedKeys = find(keyCode); 
    
    if ismember(ctrls.space, pressedKeys) == true && bullets.refractoryC >= bullets.refractory
        bullets.newBullet = [cir.cenX, cir.cenY]; 
        bullets.XY = [bullets.XY; bullets.newBullet];
        bullets.refractoryC = 1; 
    end 

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
    Screen('DrawDots', scr.window, stars.pattern, stars.size, stars.colour);
    cir.centered = CenterRectOnPointd(cir.size, cir.cenX, cir.cenY);
    if isempty(bullets.XY) == 0 
        bullets.XY = [bullets.XY(:, 1), bullets.XY(:, 2) - bullets.movePerFrame];
        bullets.delete = bullets.XY(:, 2) <= 0;
        bullets.XY(bullets.delete, :) = [];  
        if isempty(bullets.XY) == 0
            Screen('DrawDots', scr.window, bullets.XY', bullets.size, bullets.colour);
        end 
    end 
    Screen('FillOval', scr.window, cir.colour, cir.centered);     
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    stars.pattern(2, :) = stars.pattern(2, :) - stars.movePerFrame; 
    bullets.refractoryC = bullets.refractoryC + 1; 
    
    if GetSecs > timeGameDemoStart + demoT.themeLength-demoT.all; 
        Screen('TextSize', scr.window, txt.thanksSize);
        Screen('Flip', scr.window); 
        WaitSecs(demoT.blank);
        DrawFormattedText(scr.window, txt.thanks, 'center', 'center', txt.thanksColour);
        Screen('Flip', scr.window); 
        WaitSecs(demoT.showThanks);
        Screen('Flip', scr.window);
        WaitSecs(demoT.blank); 
        exitMain = true; 
    end 
end 

%~ Clear
sca;
stop(titleH); 
stop(themeH);

end 
