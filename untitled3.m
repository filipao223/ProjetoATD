[A B] = importfile('dataset_ATD_PL2.csv');

indNanB = find(isnan(B));

for k=1:length(indNanB)
    indAntesNan = (indNanB(k)-4:indNanB(k)-1);
    valAntesNan = B(indNanB(k)-4:indNanB(k)-1);
    B(indNanB(k)) = interp1(indAntesNan, valAntesNan, indNanB(k), 'pchip', 'extrap');
end


trendValues = [];

%plot(B,'-o')
j=1;
ini=1;
for t=30:30:length(B)
    fim = t-j + 1;
    tempVals = B(j:t);
    mediaTemp = mean(tempVals);
    stdTemp = std(tempVals);
    meanTemp = repmat(mediaTemp, length(tempVals), 1);
    sigmaTemp = repmat(stdTemp, length(tempVals), 1);
    
    indOutliers = find(abs(tempVals - meanTemp)>3*sigmaTemp);
    
    %disp(length(indOutliers))
    %disp(j)
    %disp(t)
    
    for k=1:1:length(indOutliers)
        if(tempVals(indOutliers(k)) > mediaTemp + 3*stdTemp)
            tempVals(indOutliers(k)) = mediaTemp + 2.5*stdTemp;
        end
        if(tempVals(indOutliers(k)) < mediaTemp - 3*stdTemp)
            tempVals(indOutliers(k)) = mediaTemp - 2.5*stdTemp;    
        end      
    end
    
     Nv = length(tempVals);
    Tv = 0:Nv-1;
    
    Tv = transpose(Tv);
    
    %Polyfits
    polyfB = polyfit(Tv, tempVals, 2);
    polyvB = polyval(polyfB, Tv);
    trendValues(j:t) = polyvB;
    
    B(j:t) = tempVals(ini:fim);
    B_noTrend(j:t) = detrend(tempVals, 'constant');
    
    % disp(j)
    j = j +30;
end

n = length(B);
Tm = 0:n-1;

%  plot(B, '-o'); 
% %plot(Tm, B, '-+', Tm, B_noTrend, '-*')
% hold on
% plot(trendValues, '*')
% plot(B_noTrend)
% hold off
% %hold off



