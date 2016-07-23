function drawScore
%% drawScore
% Shows a way to test the position of the score in the lower screen. 
% Should mean that no matter what monitor is used, the score will be
% visible. 

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
scr.vbl = Screen('Flip', scr.window);
scr.waitFrames = 1;

%~ Text Setup
txt.size = Screen('TextSize', scr.window, 30);
txt.colour = [0, 255, 0]; 
txt.score = 1; 
txt.scoreLimit = 1000000; 
txt.scoreString = [];
txt.X = 0; 
txt.Y = 0; 
txt.scoreTest = ['SCORE: ' num2str(txt.scoreLimit)];

%~ Priority set 
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);
Screen('BlendFunction', scr.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%~ Find good text placement (lower right)  
[~, ~, txt.scoreBounds] = DrawFormattedText...
    (scr.window, txt.scoreTest, scr.width-txt.X, scr.height-txt.Y, txt.colour); 
while txt.scoreBounds(3) >= scr.width || txt.scoreBounds(4) >= scr.height
    if  txt.scoreBounds(3) >= scr.width
        txt.X = txt.X + 10; 
    elseif txt.scoreBounds(4) >= scr.height
        txt.Y = txt.Y + 10; 
    end 
    [~, ~, txt.scoreBounds] = DrawFormattedText...
        (scr.window, txt.scoreTest, scr.width-txt.X, scr.height-txt.Y, txt.colour); 
end 

%~ Cover up the test text 
Screen('FillRect', scr.window, scr.background, scr.windowRect);

%~ Animation loop 
while txt.score < txt.scoreLimit
     
    %~ Convert score to string
    txt.scoreString = ['SCORE: ' num2str(txt.score)]; 

    %~ Draw score
    DrawFormattedText...
        (scr.window, txt.scoreString, scr.width-txt.X, scr.height-txt.Y, txt.colour); 

    %~ Flip screen 
    Screen('Flip', scr.window);
    
    %~ Update the score
    txt.score = txt.score + 1000;
    
end

%~ Clear screen
close all;
sca

end 
