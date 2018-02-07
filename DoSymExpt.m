function DoSymExpt

ALLOW_QUIT = true;
SKIP_SYNC = 0;
thisDateString = datestr(now(),'DDMMYYhhmmss');


try
    
    %General questions to ask before hand
    fprintf('First some demographic questions.\n\n\n');
    
    subjdata.code = input('What is the participant code? ','s');
    
    subjdata.age = input('What is the participant age? ','s');
    
    subjdata.gender = input('What is the participant gender? ','s');
    
    subjdata.grade = input('What is the participant grade? ','s'); % grade
    
    subjdata.school = input('What is the participant school? ','s');% school
    
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
    
    
    LEFT_RESP = KbName('z');
    RIGHT_RESP = KbName('m');
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
    pracStartText= 'Practice Trials';
    expStartText = 'Experimental Trials';
    instructions = 'Press the left key (z) if the number is smaller than 5 and the right key(m) if the number is greater than 5.';
    
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
    
    stimulusSize = 40;
    
    fontSize = 30;
    textWrap = 50;
    vSpacing = 1.5;
    Screen('TextSize',d.window,fontSize);
    DrawFormattedText(d.window,  instructions, 'center', 'center', d.white, textWrap,[],[],vSpacing);
    Screen('Flip', d.window);
    PressToGo(device,spaceKeyList)
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
                WaitSecs(5);
            case 2
                ShowText(d,fontSize,device,spaceKeyList,textWrap,vSpacing,[expStartText ' ' num2str(blockCounter) ' di ' num2str(p.nBlocks)]);
                WaitSecs(5);
        end
        
        KbQueueCreate(device,responseKeyList)
        [responseStruct,missed] = DoTrial(responseStruct,d,p,allTrials,device,LEFT_RESP,RIGHT_RESP,t,typeText, stimulusSize);
        
       if missed == 0
           missedInARow = 0;
       elseif missed == 1
           missedInARow = missedInARow + 1;
       end
       
       if missedInARow > 5
           disp('TOO MANY MISSED TRIALS. START AGAIN!')
           error('Start Again!')
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
