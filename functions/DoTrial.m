function  [responseStruct,missed] = DoTrial(responseStruct,d,p,allTrials,device,LeftKey,RightKey,t,typeText,stimulusSize)
LeftKey = KbName(LeftKey);
RightKey = KbName(RightKey);

% Present a trial
KbQueueStart([]);
% Draw a fixation
Screen('TextSize',d.window,40)
DrawFormattedText(d.window,'+','center','center',d.white)
Screen('Flip',d.window);
WaitSecs(p.tFixate/1000)
Screen('Flip',d.window);
WaitSecs(p.tPostFixatePause/1000);



% Add code to do the following
% if 5 missed trials or wrong
% then pause show the text
% "Fai attenzione"
% will have to push space to continue




% show the digit

thisStimulus = allTrials{t};
Screen('TextSize',d.window,stimulusSize)
DrawFormattedText(d.window,thisStimulus,'center','center',d.white);
Screen('Flip',d.window);

KbQueueFlush([]);

stimulusTime = GetSecs;

% Wait for a respnse or timeout


pressed = 0;
thekey = 0;
while pressed == 0
    
    [ pressed, firstPress] = KbQueueCheck([]); %  check if any key was pressed.
    
    if (GetSecs - stimulusTime) > (p.tTimeout / 1000)
        pressed = 2; % 2 means the trial was missed
    end
end

if pressed  == 1  % if key was pressed do the following
    firstPress(firstPress==0)=NaN; %little trick to get rid of 0s
    [pressTime, Index]=min(firstPress); % gets the RT of the first key-press and its ID
    thekey=KbName(Index); %converts KeyID to keyname
    if strcmp(thekey,'q') == 1
        %ListenChar
        sca
        error('quit early')        
    end
end

correct = 0;
keyName = 'na';
switch thekey
    case (LeftKey)
        keyName = ('left');
    case (RightKey)
        keyName = ('right');
end

disp(['thekey is ' thekey ])
disp(['the leftkey is ' LeftKey ])
disp(['the stimulus is ' str2double(thisStimulus)])
disp(['the stimulus is ' (thisStimulus)])

if str2double(thisStimulus) < 5 && strcmp(thekey,LeftKey)
    correct = 1;
end

if str2double(thisStimulus) > 5 && strcmp(thekey,RightKey)
    correct = 1;
end

missed = 0;

if pressed  == 2
    correct = 0;
    pressTime = stimulusTime; % set the press time to stimulus time, so that the RT will be 0
    missed = 1; % mark the trial as missed
end

if correct == 0
    missed = 1; % mark the trial as missed if it's incorrect
end

thisRT = (pressTime - stimulusTime) * 1000; % the reaction time in ms

KbQueueStop([]);

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
