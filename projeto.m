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

    %Tendencias
    ValoresLidos(j:t) = tempVals(ini:fim);
    ValuesDetrend(j:t) = detrend(tempVals, 'constant');
    ValoresLidos_noTrend0(j:t) = ValoresLidos_noTrend(j:t) - ValuesTrend(j:t);

    polyfValues = polyfit(Tv, tempVals, 2);
    polyvValues = polyval(polyfValues, Tv);
    ValoresLidos_noTrend2(j:t) = polyvValues;

    % disp(j)
    j = j +30;
end

n = length(ValoresLidos);
Tm = 0:n-1;

figure(1)
subplot(3,1,1);
plot(ValoresLidos);
title('Valores lidos');
subplot(3,1,2);
plot(ValuesTrend);
title('Tendencia');
subplot(3,1,3);
plot(ValoresLidos_noTrend);
title('Valores lidos sem tendencia')
