chooseSong = 3; 

if chooseSong == 1 
    [y, Fs] = audioread('snippet.wav');
    snipH = audioplayer(y, Fs);
    play(snipH); 
elseif chooseSong == 2
    [y, Fs] = audioread('theme.wav');
    themeH = audioplayer(y, Fs);
    play(themeH); 
elseif chooseSong == 3
    [y, Fs] = audioread('title.wav');
    titleH = audioplayer(y, Fs);
    play(titleH); 
end 

