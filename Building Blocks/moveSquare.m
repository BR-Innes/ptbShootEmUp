function moveSquare 
%% moveSquare 
% A mod of Peter Scarfe's tutorial to allow the square to move on a diagonal
% if you hold down two directional keys. 
% Reference: http://peterscarfe.com/keyboardsquaredemo.html

%~ Clear the workspace and the screen
sca;
close all;
clearvars;
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

%~ Square Variables
sqr.size = [0 0 200 200];
sqr.cenX = []; 
sqr.cenY = []; 
sqr.colour = [255, 0, 0]; 
sqr.centered = []; 

%~ Controls 
% For diagonal movement I sort the key combinations because find gives you
% them in order, and it's important for evaluating whether the key combos
% equal your conditionals 
ctrls.esc = KbName('ESCAPE');
ctrls.up = KbName('UpArrow');
ctrls.down = KbName('DownArrow');
ctrls.left = KbName('LeftArrow');
ctrls.right = KbName('RightArrow');
ctrls.leftUp = sort([ctrls.left, ctrls.up]); 
ctrls.rightUp = sort([ctrls.right, ctrls.up]); 
ctrls.leftDown = sort([ctrls.left, ctrls.down]); 
ctrls.rightDown = sort([ctrls.right, ctrls.down]);
ctrls.movePerPress = 10; % pixels 

%~ PTB Setup 
PsychDefaultSetup(2);
screens = Screen('Screens');
scr.number = max(screens);

scr.foreground = WhiteIndex(scr.number);
scr.background = BlackIndex(scr.number);

[scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.number, scr.background);
[scr.width, scr.height] = Screen('WindowSize', scr.window);
[scr.cenX, scr.cenY] = RectCenter(scr.windowRect);
scr.ifi = Screen('GetFlipInterval', scr.window);

%~ Square Setup
sqr.cenX = scr.cenX;
sqr.cenY = scr.cenY;

% Sync us and get a time stamp
scr.vbl = Screen('Flip', scr.window);
scr.waitFrames = 1;

% Maximum priority level
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);

% Loop the animation until the escape key is pressed
while scr.exit == false 
   
    % Check the keyboard to see if a button has been pressed
    [~,~,keyCode] = KbCheck;
    pressedKeys = find(keyCode); 
    
    % Depending on the button press, either move ths position of the square
    % or exit the demo
    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            scr.exit = true;
        elseif pressedKeys == ctrls.left
            sqr.cenX = sqr.cenX - ctrls.movePerPress;
        elseif pressedKeys == ctrls.right
            sqr.cenX = sqr.cenX + ctrls.movePerPress;
        elseif pressedKeys == ctrls.up
            sqr.cenY = sqr.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.down
            sqr.cenY = sqr.cenY + ctrls.movePerPress;
        end 
    elseif length(pressedKeys) == 2
        if pressedKeys == ctrls.leftUp
            sqr.cenX = sqr.cenX - ctrls.movePerPress;
            sqr.cenY = sqr.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.leftDown
            sqr.cenX = sqr.cenX - ctrls.movePerPress;
            sqr.cenY = sqr.cenY + ctrls.movePerPress;
        elseif pressedKeys == ctrls.rightUp
            sqr.cenX = sqr.cenX + ctrls.movePerPress;
            sqr.cenY = sqr.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.rightDown
            sqr.cenX = sqr.cenX + ctrls.movePerPress;
            sqr.cenY = sqr.cenY + ctrls.movePerPress;
        end 
    end 

    % We set bounds to make sure our square doesn't go completely off of
    % the screen
    if sqr.cenX < 0
        sqr.cenX = 0;
    elseif sqr.cenX > scr.width
        sqr.cenX = scr.width;
    end

    if sqr.cenY < 0
        sqr.cenY = 0;
    elseif sqr.cenY > scr.height
        sqr.cenY = scr.height;
    end

    % Center the rectangle on the centre of the screen
    sqr.centered = CenterRectOnPointd(sqr.size, sqr.cenX, sqr.cenY);

    % Draw the rect to the screen
    Screen('FillRect', scr.window, sqr.colour, sqr.centered);

    % Flip to the screen
    Screen('FillRect', scr.window, sqr.colour, sqr.centered);
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    
end

% Clear the screen
sca;
end 
