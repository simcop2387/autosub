%what is W and m?
%WBlkData would APPEAR to be something like the sound sample coming in, NOT the FT results

function Voice=VUDecision(WBlkData,W,m)

% Pattern recognition on the input data.
        
  count=0;                                          % Set initial values.
  sum=0;
  sum1=0;
  sum2=0;
  sum3=0;
       
  e=1.0e-5;
  
  Block_sample=length(WBlkData);
  
  for j=1: Block_sample
     index=j; 
       if (index>1)
          if (sign(WBlkData(index))-sign(WBlkData(index-1))~=0)   %if the sign of the data changes 
             count=count+1;                                       %increase the zero crossing number
          end
        end
          
   sum=sum+WBlkData(index)^2;
          
   if (index>=2)
       sum1=sum1+WBlkData(index)*WBlkData(index-1);
       else
          sum1=sum1+WBlkData(index)*WBlkData(index);
   end
           sum2=sum2+WBlkData(index)^2;
       if (index>1)
              sum3=sum3+WBlkData(index-1)^2;
           else
              sum3=sum3+WBlkData(index)^2;
           end
       end
        
      y(1)=count;
      
      sum=sum/Block_sample;
      sum=e+sum;
      y(2)=10*log10(sum); %log energy from the paper, not difficult to understand
      
      y(3)=sum1/sqrt(sum2*sum3); %autocorrelation? i would have done these in the reverse order and removed the need for sum2, saves time and memory
      
%what the fuck is this next block?
      for l=1:3
         d(l)=(y.'-m(:,l)).'*inv(W(:,:,l))*(y.'-m(:,l));
      end
      
      [temp,result]=min(abs(d));
      
      if (result>2) 
         Voice=1;
      else
         Voice=0;
      end
      
      return;
      
