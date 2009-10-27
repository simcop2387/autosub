function count=VUzerocoss(x)

len=length(x);	%get the length of the data 

count=0;	%set inital value of the zero crossing number 

for i=2:len
   if sign(x(i))-sign(x(i-1))~=0 %if the sign of the data changes 
      count=count+1;					%increase the zero crossing number
   end
end
