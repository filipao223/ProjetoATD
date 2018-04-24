[Datas ValoresLidos] = importfile('dataset_ATD_PL2.csv');

indNan = find(isnan(ValoresLidos));

for k=1:length(indNan)
    indAntesNan = (indNan(k)-4:indNan(k)-1);
    valAntesNan = ValoresLidos(indNan(k)-4:indNan(k)-1);
    ValoresLidos(indNan(k)) = interp1(indAntesNan, valAntesNan, indNan(k), 'pchip', 'extrap');
end


trendValues = [];

%plot(ValoresLidos,'-o')
j=1;
ini=1;
for t=30:30:length(ValoresLidos)
    fim = t-j + 1;
    tempVals = ValoresLidos(j:t);
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

    %Tendencia
    polyfValues = polyfit(Tv, tempVals, 2);
    polyvValues = polyval(polyfValues, Tv);
    trendValues(j:t) = polyvValues;

    ValoresLidos(j:t) = tempVals(ini:fim);
    ValuesDetrend = detrend(tempVals, 'constant');
    ValoresLidos_noTrend(j:t) = ValoresLidos_noTrend(j:t) - ValuesDetrend;

    % disp(j)
    j = j +30;
end

n = length(ValoresLidos);
Tm = 0:n-1;

%  plot(ValoresLidos, '-o');
% %plot(Tm, ValoresLidos, '-+', Tm, ValoresLidos_noTrend, '-*')
% hold on
% plot(trendValues, '*')
% plot(ValoresLidos_noTrend)
% hold off
% %hold off
