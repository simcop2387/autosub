function [W,m]=VUS_Detection_training(WT,WL,Shift)

load -ascii rain8k.dat;
Data=rain8k;

DataLen=length(Data);
blkMax=floor((DataLen-WL)/Shift); 	% Max Block Number

s=zeros(0,0);

for k=1:floor(blkMax)		   % Discard the last frame for simplicity					
   
   % Get the blk data 						
   blkStart=1+(k-1)*Shift;		% Start of the current Blk
   blkEnd=blkStart+WL-1;		% End of the Blk
   OBlkData=Data(blkStart:blkEnd);
   WBlkData=PreProc(OBlkData,WT,WL);	% Preprocessing the OBlkData with window;
   s=[s.',WBlkData.'].';   
end

Block_sample=WL;
Num_block=blkMax;

% Manually count Voiced/Unvoiced/Silent segments of the training data.

% N(i): the number of 500-sample blocks manually classified as class i in the training set.
% class 1: silence
% class 2: unvoiced
% class 3: voiced

%s=Data1;                          % s array stores data.

N(1)=0; N(2)=0; N(3)=0;

c1=1; c2=1; c3=1;                % c1, c2, c3: index of array storing starting point of each classified block.

% "manually-decided" three classes (actually automatically decided by energy function).

for i=1:Num_block
   sum=0;
   for j=1:Block_sample
      sum=sum+s((i-1)*Block_sample+j)^2;                 % energy function
   end
   sum=sum/Block_sample;
   
   if (sum<=0.00003)                                       % Criterion for silence determination.
      N(1)=N(1)+1;
      silence(c1)=(i-1)*Block_sample+1;                  % starting index of silence block;
      c1=c1+1;
   end
   
   if (sum>0.00003 & sum<=0.00006)
      N(2)=N(2)+1;
      unvoiced(c2)=(i-1)*Block_sample+1;                  % starting index of unvoiced block; 
      c2=c2+1;
   end
   
   if (sum>0.00006)
      N(3)=N(3)+1;
      voiced(c3)=(i-1)*Block_sample+1;                    % starting index of voiced block;
      c3=c3+1;
   end
   
end

len=length(voiced);

s_bin=zeros(1,Block_sample*Num_block);
for (i=1:len)
   for (j=1:Block_sample)
      s_bin(voiced(i)+j)=1;
   end
end

      
% Estimation of the means and the covariances.

% m(:,i): mean vector of class i.
% W: covariance matrix.
%    W(:,:,1): covariance matrix for classfied block as "silence".
%    W(:,:,2): covariance matrix for classfied block as "unvoiced".
%    W(:,:,3): covariance matrix for classfied block as "voiced".
% In the current program, only 3 measurements are used.  Each of above three matrix is 3x3 dimension.
% x(i,j): measurement vector for the class j according to the measure i.

m(:,1)=[0,0,0].';                             % Initialize mean vector.

W(:,:,1)=zeros(3,3);

% For measurements belonging to Silence.

for k=1:N(1)
   
   % Measurement #1----the number of zero crossings in the block.
      count=0;	                                          %set inital value of the zero crossing number 
        for index=silence(k)+1:silence(k)+Block_sample-1
         if (sign(s(index))-sign(s(index-1))~=0)         %if the sign of the data changes 
            count=count+1;					                  %increase the zero crossing number
         end
        end
      x(1,1)=count;
        
   % Measurement #2----log10 energy. e is a small positive constant added to prevent the computing of log10 of zero
      e=1.0e-5;
      sum=0; 
        for index=silence(k):silence(k)+Block_sample-1
           sum=sum+s(index)^2;
        end
        sum=sum/Block_sample;
        sum=e+sum;
      x(2,1)=10*log10(sum);                               % energy function.
        
   % Measurement #3----Normalized autocorrelation coefficient at unit sample delay.
      sum1=0;                                             % sum1, sum2 and sum3 are temporary variables for computing normalized autocorrelation coefficient at unit sample delay.
      sum2=0;
      sum3=0;
        for index=silence(k):silence(k)+Block_sample-1 
           if (index>=2)
              sum1=sum1+s(index)*s(index-1);
           else
              sum1=sum1+s(index)*s(index);
           end
           sum2=sum2+s(index)^2;
           if (silence(k)>1)
              sum3=sum3+s(index-1)^2;
           else
              sum3=sum3+s(index)^2;
           end
        end
       x(3,1)=sum1/sqrt(sum2*sum3);
           
       m(:,1)=m(:,1)+x(:,1);                               % add-up measurements vector
       
       W(:,:,1)=W(:,:,1)+x(:,1)*x(:,1).';                  % add-up first term of covariance matrix
    end
    
    m(:,1)=m(:,1)/N(1);                                    % mean vector 
    
    W(:,:,1)=W(:,:,1)/N(1)-m(:,1)*m(:,1).';                % covariance matrix
    
    for i=1:3
       for j=1:3
          W_normal(i,j,1)=W(i,j,1)/sqrt(W(i,i,1)*W(j,j,1));  % normalize covariance matrix
       end
    end
    
 % For measurements belonging to Unvoiced.  Algorithms are similar those used in Silence section  
 
 m(:,2)=[0,0,0].';
 
 W(:,:,2)=zeros(3,3);

  for k=1:N(2)
   
   % Measurement #1----the number of zero crossings in the block.
      count=0;	                                %set inital value of the zero crossing number 
        for index=unvoiced(k)+1:unvoiced(k)+Block_sample-1
         if (sign(s(index))-sign(s(index-1))~=0)         %if the sign of the data changes 
            count=count+1;					        %increase the zero crossing number
         end
        end
      x(1,2)=count;
        
   % Measurement #2----log10 energy. e is a small positive constant added to prevent the computing of log10 of zero
      e=1.0e-5;
      sum=0; 
        for index=unvoiced(k):unvoiced(k)+Block_sample-1
           sum=sum+s(index)^2;
        end
        sum=sum/Block_sample;
        sum=e+sum;
      x(2,2)=10*log10(sum);
        
   % Measurement #3----Normalized autocorrelation coefficient at unit sample delay.
      sum1=0;
      sum2=0;
      sum3=0;
        for index=unvoiced(k):unvoiced(k)+Block_sample-1 
           if (index>=2)
              sum1=sum1+s(index)*s(index-1);
           else
              sum1=sum1+s(index)*s(index);
           end
           sum2=sum2+s(index)^2;
           if (unvoiced(k)>1)
              sum3=sum3+s(index-1)^2;
           else
              sum3=sum3+s(index)^2;
           end
        end
       x(3,2)=sum1/sqrt(sum2*sum3);
           
       m(:,2)=m(:,2)+x(:,2);
       
       W(:,:,2)=W(:,:,2)+x(:,2)*x(:,2).';
    end
    
    m(:,2)=m(:,2)/N(2);
    
    W(:,:,2)=W(:,:,2)/N(2)-m(:,2)*m(:,2).';
    
    for i=1:3
       for j=1:3
          W_normal(i,j,2)=W(i,j,2)/sqrt(W(i,i,2)*W(j,j,2));
       end
    end

  % For measurements belonging to Voiced.  Algorithms are similar to those used in Silence section.
 
   m(:,3)=[0,0,0].';
   
   W(:,:,3)=zeros(3,3);
   
  for k=1:N(3)
   
   % Measurement #1----the number of zero crossings in the block.
      count=0;	                                %set inital value of the zero crossing number 
        for index=voiced(k)+1:voiced(k)+Block_sample-1
         if (sign(s(index))-sign(s(index-1))~=0)         %if the sign of the data changes 
            count=count+1;					        %increase the zero crossing number
         end
        end
      x(1,3)=count;
        
   % Measurement #2----log10 energy. e is a small positive constant added to prevent the computing of log10 of zero
      e=1.0e-5;
      sum=0; 
        for index=voiced(k):voiced(k)+Block_sample-1
           sum=sum+s(index)^2;
        end
        sum=sum/Block_sample;
        sum=e+sum;
      x(2,3)=10*log10(sum);
        
   % Measurement #3----Normalized autocorrelation coefficient at unit sample delay.
      sum1=0;
      sum2=0;
      sum3=0;
        for index=voiced(k):voiced(k)+Block_sample-1 
           if (index>=2)
              sum1=sum1+s(index)*s(index-1);
           else
              sum1=sum1+s(index)*s(index);
           end
           sum2=sum2+s(index)^2;
           if (voiced(k)>1)
              sum3=sum3+s(index-1)^2;
           else
              sum3=sum3+s(index)^2;
           end
        end
       x(3,3)=sum1/sqrt(sum2*sum3);
           
       m(:,3)=m(:,3)+x(:,3);
       
       W(:,:,3)=W(:,:,3)+x(:,3)*x(:,3).';
    end
    
    m(:,3)=m(:,3)/N(3);
    
    W(:,:,3)=W(:,:,3)/N(3)-m(:,3)*m(:,3).';
    
    for i=1:3
       for j=1:3
          W_normal(i,j,3)=W(i,j,3)/sqrt(W(i,i,3)*W(j,j,3));
       end
    end
    
   



