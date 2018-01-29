function  responseStruct = DoTrial(responseStruct,d,p,allTrials,device,LeftKey,RightKey,t,typeText)
% Present a trial

% Draw a fixation
Screen('TextSize',d.window,40)
DrawFormattedText(d.window,'+','center','center',d.white)
Screen('Flip',d.window);
WaitSecs(p.tFixate/1000)
Screen('Flip',d.window);
WaitSecs(p.tPostFixatePause/1000);




% show the digit

thisStimulus = allTrials{t};
DrawFormattedText(d.window,thisStimulus,'center','center',d.white);
Screen('Flip',d.window);

stimulusTime = GetSecs;

% Wait for a respnse or timeout


KbQueueFlush(device);
KbQueueStart(device);

pressed = 0;
thekey = 0;
while pressed == 0
    
    [ pressed, firstPress] = KbQueueCheck(device); %  check if any key was pressed.
    
    if (GetSecs - stimulusTime) > (p.tTimeout / 1000)
        pressed = 2;
        firstPress = zeros(1,256);
        firstPress(KbName('space')) = GetSecs;
    end
end

if pressed  == 1  % if key was pressed do the following
    firstPress(firstPress==0)=NaN; %little trick to get rid of 0s
    [pressTime, Index]=min(firstPress); % gets the RT of the first key-press and its ID
    thekey=KbName(Index); %converts KeyID to keyname
    if strcmp(thekey,'q') == 1
        ListenChar
        sca
        error('quit early')        
    end
end

correct = 0;
keyName = 'na';
switch thekey
    case LeftKey
        keyName = ('left');
    case RightKey
        keyName = ('right');
end

if str2double(thisStimulus) < 5 && strcmp(thekey,LeftKey)
    correct = 1;
end

if str2double(thisStimulus) > 5 && strcmp(thekey,RightKey)
    correct = 1;
end

if pressed  == 2
    correct = 9;
    pressTime = GetSecs;
end

thisRT = (pressTime - stimulusTime) * 1000; % the reaction time in ms

KbQueueStop(device);

responseStruct(t).stimulus = thisStimulus;
responseStruct(t).thekey = thekey;
responseStruct(t).keyName = keyName;
responseStruct(t).correct = correct;
responseStruct(t).stimulusTime = stimulusTime;
responseStruct(t).pressTime = pressTime;
responseStruct(t).RT = thisRT;
responseStruct(t).type = typeText;
Screen('Flip',d.window);
WaitSecs(p.tInterTrial/1000);
