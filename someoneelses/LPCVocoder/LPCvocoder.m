function LPCvocoder(WL,WT,Shift,PDT,VDT,LPT,EGT,Data,FS);
% function LPCvocoder()
% By Yuanbin Guo for Course Project ELEC532
%

POrder=10;

disp('In LPCvocoder');

Framerate=Shift;

DataLen=length(Data);
blkMax=floor((DataLen-WL)/Shift); 	% Max Block Number
outSpeech=zeros(blkMax,WL);

% The data will be divided to frames with a length WL and Frameshift as Shift;
% 1																							N	 
% |_____________________________________________________________________|
% |1_____________WL|
%					|1________________WL|
%					Shift
%											...
%																	 |1________________WL|
numcoef=0;
% [W,m]=GetPara_training;
[W,m]=VUS_Detection_training(WT,WL,Shift);
for k=1:floor(blkMax)		   % Discard the last frame for simplicity					
	% Get the blk data 						
   blkStart=1+(k-1)*Shift;		% Start of the current Blk
   blkEnd=blkStart+WL-1;		% End of the Blk
   OBlkData=Data(blkStart:blkEnd);
   [WBlkData,w]=PreProc(OBlkData,WT,WL);	% Preprocessing the OBlkData with window;
   
   % 1. The first step, get the LPC coefficients according to method LPT;
   Drawmode = 'nd';	% do not plot the result;
   [Refl_coef,Aparm,error_f,error_b,Gain]=DoLPCAna(WBlkData,POrder,LPT,Drawmode); 

   % 2. Do Voice/Unvoice Decision here according to the method 'VDT';
   Voice(k)=VUDecision(WBlkData,W,m);         % pseudo code here;

   switch EGT
   case '2S'
      if Voice(k)==1
   	   Pitch=PitchDetection(WBlkData,PDT); % pseudo code here;
	   else 
      	Pitch = 0;
      end
      % 3. Do Pitch Detection here according to the method of 'PDT';
	   % 4. Do the Quantization and Encoding here;
	   % bitStream=EncodeParms(Voice,Pitch,Refl_coef,Gain);
	   % 5.Do the DocodeParms here
   	% [Voice,Pitch,Refl_coef,Gain]=DecodeParms(bitStream);
      Excitation=TSEGenerator(Voice(k),Pitch,Gain,WL);
   case 'WR'
      error_f=error_f./w;
      [Excitation,nnulcoef]= WRELP(Voice,Gain,error_f,WL);
      numcoef=numcoef+nnulcoef;
      disp('nnulcoef');disp(nnulcoef);
      disp('numcoef');disp(numcoef);
   otherwise
      Excitation=error_f./w;
   end
   Synth=Synthesizer(Excitation,Refl_coef);
   tmpBlk=PostProc(Synth);
   for i=1:WL
      outSpeech(k,i)=tmpBlk(i);
   end
      
   disp('processing frame #');disp(k);
end

finalSpeech=[];
for k=1:blkMax
   finalSpeech=[finalSpeech outSpeech(k,:)];
end

disp('press a key to see and listen the reconstructed speech');
pause;

subplot(2,1,1);plot(Data);
subplot(2,1,2);plot(finalSpeech);
% sound(Data,FS);
sound(finalSpeech,FS);

     
   
   
   
   
   
   




