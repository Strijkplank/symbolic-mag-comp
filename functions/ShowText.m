function ShowText(d,fontSize,device,keyList,textWrap,vSpacing,text)

Screen('TextSize',d.window,fontSize);
DrawFormattedText(d.window, text, 'center', 'center', d.white, textWrap,[],[],vSpacing);
Screen('Flip', d.window);
PressToGo(device,keyList)
Screen('Flip', d.window);