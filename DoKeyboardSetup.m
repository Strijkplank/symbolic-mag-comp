addpath([cd filesep 'functions'])
addpath([cd filesep 'functions' filesep 'my-ptb-funcs'])
if length(GetKeyboardIndices) == 1
    deviceIndexToUse = GetKeyboardIndices;
else
    [deviceNameToUse, deviceIndexToUse] = FindKeyboard();
end



msgbox('You are now going to be asked to select a file that was created during the calibration of the non-symbolic task, so make sure this has been done')

[FileName,PathName,FilterIndex] = uigetfile('*.mat','Select the file called params.mat in the functions subfolder in the Nonsymbolic task folder','params.mat');



load([PathName filesep 'params.mat'])


onecmpixelheight = mean(horzcat(params.rawInfo.sizeparams.rectWidth));

Screen('Preference', 'SkipSyncTests', 1)
[w,rect] = PsychImaging('OpenWindow',0,[]);

for ftsize = 1: 400

Screen('TextSize',w,ftsize);

[xCenter,yCenter] = RectCenter(rect); % get the centre coordinates
Screen('TextSize',w,ftsize) % Set text size to 12
DrawFormattedText(w,'0','center','center')
Screen('Flip',w)
M = Screen('GetImage',w);


%find top line
y = 1;
e = 0;
while e == 0
    pixels = find(M(y,:) ~= 255);
    if ~isempty(pixels)
        e = 1;
    end
    y = y + 1;
end

top = y - 1;

y = size(M,1);
e = 0;
while e == 0
    pixels = find(M(y,:) ~= 255);
    if ~isempty(pixels)
        e = 1;
    end
    y = y - 1;
end

bottom = y + 1;

%sca;

fsizes(ftsize,1) = abs(top-bottom)/onecmpixelheight;
end

sca


[value, index] = min(abs(fsizes - 2));






save('fontsize.ini','index','-ascii')
save('keyboard.ini','deviceIndexToUse','-ascii')
disp('DONE!')