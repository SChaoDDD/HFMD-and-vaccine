function week=day_2_week(data,weeknumber)
         data1=zeros(1,weeknumber);
         for i=1:weeknumber
             for j=1+(i-1)*7:i*7
                 data1(i)=data1(i)+data(j);
             end
         end
         week=data1;
end