function DoSymExpt
rng('shuffle') % set the randomisation seed
clear all
clear screen
clear Screen
sca

ALLOW_QUIT = true;
SKIP_SYNC = 0;
MAX_MISSED = 5; % a maximum of 5 missed trials/incorrect trials before it displays a warning message
thisDateString = datestr(now(),'DDMMYYhhmmss');


try
    
    %General questions to ask before hand
    fprintf('First some demographic questions.\n\n\n');
    
    subjdata.code = input('Wat is uw proefpersoon-nummer?','s');
    
    subjdata.age = input('Wat is uw leeftijd?','s');
    
    subjdata.gender = input('Wat is uw geslacht? Gelieve M voor Mannelijk of V voor Vrouwelijk in te geven. ','s');
    
    
    subjdata.grade = 'Adult'
    
        
    subjdata.school = 'Leuven'
    
    subjdata.runtime = datestr(now,0);
    
    addpath('functions')
    addpath('functions/my-ptb-funcs')
    
    KbName('UnifyKeyNames');
    
    [d,ME] = IntializeDisplay(SKIP_SYNC);
    
    if length(GetKeyboardIndices) == 1
        device = GetKeyboardIndices
    else
        device = load('keyboard.ini','-ASCII')
    end
    
    
    
    
    
    LEFT_RESP = KbName('f');
    RIGHT_RESP = KbName('j');
    SPACE_RESP = KbName('space');
    QUIT_RESP = KbName('q');
    
    responseKeyList = zeros(256,1);
    responseKeyList(LEFT_RESP) = 1;
    responseKeyList(RIGHT_RESP) = 1;
    if ALLOW_QUIT == true
        responseKeyList(QUIT_RESP) = 1;
    end
    
    spaceKeyList = zeros(256,1);
    spaceKeyList(SPACE_RESP) = 1;
    
    %% general paradigm options
    
    
    % instructions and block markers
    pracStartText= 'Practice Trials (press space)';
    expStartText = 'Experimental Trials (press space)';
    instructions = 'Druk op de linker toets (f) als het getal kleiner is als 5, en druk op de rechter toets (j) als het getal groter is als 5.' 'Probeer zo snel en accuraat mogelijk te antwoorden' 'Druk op de spatiebalk om verder te gaan';
    
    % stimlus and trial options
    
    p.trialsPerStim = 10; % number of experimental trials per block
    p.nBlocks = 2; % number of experimental blocks
    p.pracBeforeEveryBlock = 0; % practise block before each experimental
    % block 1 = YES; 0 = N0
    p.pracTrialsPerStim = 2; % number of trials for each practice stimulus
    p.stimItems = {'1' '4' '6' '9'}; % the actual stimuli to be used
    
    % trial timing
    
    p.tFixate = 200; % fixation cross time
    p.tPostFixatePause = 1000; % Pause after fixation cross
    p.tTimeout = 3000; % trial timeout
    p.tInterTrial = 400; % inter trial interval
    
    %% generate the trial arrays
    
    
    
    % generate practice block
    
    % mark where the instructions will be presented and the type of
    % instructions
    
    
    practiseBlockStims = repmat(p.stimItems,1,p.pracTrialsPerStim);
    practiseBlockMarks = repmat(zeros(1,length(p.stimItems)),1,p.pracTrialsPerStim);
    practiseBlockMarks(1) = 1;
    
    
    practiseBlockTypes = repmat(zeros(1,length(p.stimItems))+1,1,p.pracTrialsPerStim);
    
    % generate experimental block
    experimentalBlockStims = repmat(p.stimItems,1,p.trialsPerStim);
    experimentalBlockMarks = repmat(zeros(1,length(p.stimItems)),1,p.trialsPerStim);
    experimentalBlockMarks(1) = 2;
    experimentalBlockTypes = repmat(zeros(1,length(p.stimItems))+2,1,p.trialsPerStim);
    
    
    
    
    
    
    if p.pracBeforeEveryBlock == 0
        allExperimentalTrials = [];
        allExperimentalMarks = [];
        allExperimentalTypes = [];
        for i = 1 : p.nBlocks
            allExperimentalTrials = [allExperimentalTrials,Shuffle(experimentalBlockStims)];
            allExperimentalMarks = [allExperimentalMarks,experimentalBlockMarks];
            allExperimentalTypes = [allExperimentalTypes,experimentalBlockTypes];
        end
        
        allTrials = [practiseBlockStims,allExperimentalTrials];
        allMarks = [practiseBlockMarks,allExperimentalMarks];
        allTypes = [practiseBlockTypes,allExperimentalTypes];
        
    else
        error('Whoops! Haven''t coded that option!')
    end
    
    %% present the instructions
    
    stimulusSize = load('fontsize.ini','-ascii');
    
    fontSize = 30;
    textWrap = 50;
    vSpacing = 1.5;
    Screen('TextSize',d.window,fontSize);
    DrawFormattedText(d.window,  instructions, 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    PressToGo([],spaceKeyList)
    Screen('Flip', d.window);
    
    %% present the trials
    responseStruct = struct();
    blockCounter = 1;
    %ListenChar(2)
    HideCursor
    missedInARow = 0;
    for t = 1 : size(allTrials,2)
        
        thisMark = allMarks(t);
        thisType = allTypes(t) ;
        switch thisType
            case 1
                typeText = 'prac';
            case 2
                typeText = 'exp';
        end
        
        switch thisMark
            case 1
                ShowText(d,fontSize,device,spaceKeyList,textWrap,vSpacing,pracStartText);
                WaitSecs(2);
            case 2
                ShowText(d,fontSize,device,spaceKeyList,textWrap,vSpacing,[expStartText ' ' num2str(blockCounter) ' di ' num2str(p.nBlocks)]);
                WaitSecs(2);
        end
        
        KbQueueCreate([],responseKeyList)
        
        [responseStruct,missed] = DoTrial(responseStruct,d,p,allTrials,device,LEFT_RESP,RIGHT_RESP,t,typeText, stimulusSize);
        
       if missed == 0
           missedInARow = 0;
       elseif missed == 1
           missedInARow = missedInARow + 1;
       end
       
       if missedInARow >= MAX_MISSED

           % show a warning
           ShowText(d,fontSize,device,spaceKeyList,textWrap,vSpacing,'Fai attenzione');
           missedInARow = 0;
           Screen('Flip',d.window);
       end
        
    end
    
    
    DrawFormattedText(d.window,  'THE END', 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    WaitSecs(5)
    
    if exist('data','dir')==0
        mkdir('data')
    end
    
    save(['data/',subjdata.code,'_data.mat'],'responseStruct','subjdata');
    ListenChar
    ShowCursor
    sca
catch ME
    ListenChar
    sca
    ShowCursor
    if exist('error','dir')==0
        mkdir('error')
    end
    save(['error/',subjdata.code,'_error.mat']);
end
