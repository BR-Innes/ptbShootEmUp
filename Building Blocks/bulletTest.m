function bulletTest 

%~ Clear the workspace and the screen
sca;
close all;
clearvars;
myGraphicsTimingSucksMode = true; 
KbName('UnifyKeyNames'); 

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
cir.size = [0 0 100 100];
cir.cenX = []; 
cir.cenY = []; 
cir.colour = [255, 0, 0]; 
cir.centered = []; 



%~ Controls 
% For diagonal movement I sort the key combinations because find gives you
% them in order, and it's important for evaluating whether the key combos
% equal your conditionals 
ctrls.esc = KbName('ESCAPE');
ctrls.up = KbName('UpArrow');
ctrls.down = KbName('DownArrow');
ctrls.left = KbName('LeftArrow');
ctrls.right = KbName('RightArrow');
ctrls.fire = KbName('SPACE'); 
ctrls.leftUp = sort([ctrls.left, ctrls.up]); 
ctrls.rightUp = sort([ctrls.right, ctrls.up]); 
ctrls.leftDown = sort([ctrls.left, ctrls.down]); 
ctrls.rightDown = sort([ctrls.right, ctrls.down]);
ctrls.movePerPress = 10; % pixels

%~Bullets
bullets.XY = []; 

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

%~ Circle Setup
cir.cenX = scr.cenX;
cir.cenY = scr.cenY;

%~ Sync
scr.vbl = Screen('Flip', scr.window);
scr.waitFrames = 1;

%~ Priority Set 
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);
bullets.refractory = 10; 
bullets.refractoryC = 10; 

%~ Animation Loop 
while scr.exit == false 
    
    %~ Check Keys 
    [~,~,keyCode] = KbCheck;
    pressedKeys = find(keyCode); 
    
    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            scr.exit = true;
        elseif pressedKeys == ctrls.left
            cir.cenX = cir.cenX - ctrls.movePerPress;
        elseif pressedKeys == ctrls.right
            cir.cenX = cir.cenX + ctrls.movePerPress;
        elseif pressedKeys == ctrls.up
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.down
            cir.cenY = cir.cenY + ctrls.movePerPress;
        elseif pressedKeys == ctrls.fire && bullets.refractoryC >= bullets.refractory
            bullets.newBullet = [cir.cenX, cir.cenY]; 
            bullets.XY = [bullets.XY; bullets.newBullet];
            bullets.refractoryC = 1; 
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

    %~ Replot circle 
    cir.centered = CenterRectOnPointd(cir.size, cir.cenX, cir.cenY);

    %~ Delete bullets that have moved too high to the bottom
    if isempty(bullets.XY) == 0 
        bullets.XY = [bullets.XY(:, 1), bullets.XY(:, 2) - 10];
        bullets.delete = bullets.XY(:, 2) <= 0;
        bullets.XY(bullets.delete, :) = [];  
        if isempty(bullets.XY) == 0
            Screen('DrawDots', scr.window, bullets.XY', 4, [255 255 255]);
        end 
    end 

    %~ Flip 
    Screen('FillOval', scr.window, cir.colour, cir.centered);
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    
    bullets.refractoryC = bullets.refractoryC + 1; 
    
end

%~ Clear screen
sca;

end 
