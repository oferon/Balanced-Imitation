% For each song we calculate features
thresh=55;
Tall=[];
d=dir('*.wav');
PitchAll=[]; FMAll=[]; EntropyAll=[];
for i=1:length(d)
    fname=strcat(d(i).folder, '/', d(i).name);
    fname
    snd=SAT_sound(fname,0);
    Pitch=snd.features.pitch(snd.features.amplitude>thresh);
    Pitch1=Pitch(Pitch>0 & Pitch<8000);
    logPitch=log(Pitch1);
    PitchAll=[PitchAll,randsample(Pitch1,min(length(Pitch1),1000))];
    %PitchAll=[PitchAll,Pitch1];
    
    ent=snd.features.entropy(snd.features.amplitude>thresh);
    ent1=ent(Pitch>0 & Pitch<8000);
    logEntropy=log(-ent1);
    EntropyAll=[EntropyAll,randsample(ent1,min(length(Pitch1),1000))];
    %EntropyAll=[EntropyAll,ent1];
    
    Pitchs=smooth(Pitch1,15,'sgolay');
    FMr=diff(Pitchs);
    ai=FMr;
    FMr(ai>0)=log(FMr(ai>0));
    FMr(ai<0)=-log(-FMr(ai<0));
    FMr=[FMr;1]; % add one to make all vectors similar length
    FMr=FMr';
    FMAll=[FMAll,randsample(FMr,min(length(Pitch1),1000))];
    %FMAll=[FMAll,FMr];
    

    % now for each pitch range find # data in clusters
    
    VlowPitchPlus=length(FMr(logPitch<6.1 & FMr>0));
    VlowPitchMinus=length(FMr(logPitch<6.1 & FMr<0));
    
    lowPitchPlus=length(FMr(logPitch>6 & logPitch<6.6 & FMr>1.75));
    lowPitchMinus=length(FMr(logPitch>6 & logPitch<6.6 & FMr<-2.2));
    lowPitchFM=length(FMr(logPitch>6 & logPitch<6.6 & FMr>-2.2 & FMr < 1.75));
    
    midPitchPlus=length(FMr(logPitch>6.6 & logPitch<7.2 & FMr>1.75));
    midPitchMinus=length(FMr(logPitch>6.6 & logPitch<7.2 & FMr<-2.2));
    midPitchFM=length(FMr(logPitch>6.6 & logPitch<7.2 & FMr>-2.2 & FMr < 1.75));
    
    highPitchPlus=length(FMr(logPitch>7.2 & FMr>1.75));
    highPitchMinus=length(FMr(logPitch>7.2 & FMr<-2.2));
    highPitchFM=length(FMr(logPitch>7.2 & FMr>-2.2 & FMr < 1.75));
    
    % caluclate Shannon information for 10 clusters:
    clusts=[VlowPitchPlus, VlowPitchMinus, lowPitchPlus, lowPitchMinus,lowPitchFM, midPitchPlus, midPitchMinus,midPitchFM, highPitchPlus, highPitchMinus];
    clusts(clusts==0)=0.0001;
    clustsNorm=clusts./sum(clusts);
    info=-sum(clustsNorm.*log2(clustsNorm));
    
    % show results in table
    
    T = { d(i).name, VlowPitchPlus, VlowPitchMinus, lowPitchPlus, lowPitchMinus,lowPitchFM, midPitchPlus, midPitchMinus,midPitchFM, highPitchPlus, highPitchMinus,highPitchFM, info};
    Tall=[Tall;T];
    
 
    
end


