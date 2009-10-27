function Voice=VUEnergyzero(Data) 
%Voice/UNVoice detection fuction using energy
%Data: input voice data (1,N)

speech_data=Data;

N=240;                                       % length of frame window
olap=60;                                     % amount of overlap between adjacent windows
frame=N-olap;                                % frame rate.
[B,A]=butter(10,pi*9/40);                    % lowpass filter used in voiced/unvoiced decision.

% Make sure data length evenly divides frame length
rm = rem(length(speech_data)-olap,frame);   
speech_data = speech_data(1:length(speech_data)-rm);  % Cut-off end

numblks = (length(speech_data)-olap)/frame;    % number of blocks in speech
vuv = zeros(1,numblks);                        % voiced/unvoiced for each block 

% Voiced/unvoiced decisions for each block
for k=1:numblks
   ind=(k-1)*frame;
   blkind=(ind+1):(ind+N);          % block index.
   origblk=speech_data(blkind);     % block from original data.
   vuv(k)=VU_block(origblk,B,A);   % Get voiced/unvoiced decision.
end

BACK=10;   	%backward update range limit
FORWARD=10;	%forward update range limit
ZEROTH=30;	%threshold of zerocrossing rate
zcn=zeros(1,numblks); 		%init the zero cross number for each block
for k=1:numblks
   ind=(k-1)*frame;
   blkind=(ind+1):(ind+N);          % block index.
   origblk=speech_data(blkind);     % block from original data.
   zcn(k)=VUzerocross(origblk);     % get the zerocrossing rate for each block
end
for k=2:numblks	%using  backward zero cross rate to update unv decision
   if vuv(k)==1	%if now voice, look backward 	
      counter=1;
      while (counter<k&vuv(k-counter)==0&counter<BACK)
         if zcn(k-counter)>ZEROTH  %if the zero cross rate is bigger than the threshold
            vuv(k-counter)=1;					%update the vuv
            counter=counter+1;            %update counter, limit to the range set by BACK
         else
            break;
         end
      end
   end
end
for k=2:numblks	%using  forward zero cross rate to update unv decision
   if vuv(k)==1	%if now voice, look forward 	
      counter=1;
      while (counter+k<=numblks&vuv(k+counter)==0&counter<FORWARD)
         if zcn(k+counter)>ZEROTH  %if the zero cross rate is bigger than the threshold
            vuv(k+counter)=1;					%update the vuv
            counter=counter+1;				%update counter, limit to the range set by FORWARD
         else
            break;
         end
      end
   end
end
Voice=vuv;
return;
