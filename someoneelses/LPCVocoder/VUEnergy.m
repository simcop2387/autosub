function Voice=VUEnergy(Data) 
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

Voice=vuv;
return;
