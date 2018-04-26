[Datas, ValoresLidos] = importfile('dataset_ATD_PL2.csv');

indNan = find(isnan(ValoresLidos));

%Substitui valores NaN
for k=1:length(indNan)
    indAntesNan = (indNan(k)-4:indNan(k)-1);
    valAntesNan = ValoresLidos(indNan(k)-4:indNan(k)-1);
    ValoresLidos(indNan(k)) = interp1(indAntesNan, valAntesNan, indNan(k), 'pchip', 'extrap');
end

%Inicializa vetores das tendencias
Trend0 = zeros(length(ValoresLidos), 1);
Trend1 = zeros(length(ValoresLidos), 1);
polyvValues = zeros(length(ValoresLidos), 1);

j=1;
ini=1;
for t=30:30:length(ValoresLidos)
    fim = t-j + 1;
    tempVals = ValoresLidos(j:t);
    
    %Calcular medias e desvios padrao
    mediaTemp = mean(tempVals);
    stdTemp = std(tempVals);
    meanTemp = repmat(mediaTemp, length(tempVals), 1);
    sigmaTemp = repmat(stdTemp, length(tempVals), 1);

    indOutliers = find(abs(tempVals - meanTemp)>3*sigmaTemp);
    
    %Remover outliers
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

    %Tendencia grau 0
    ValoresLidos(j:t) = tempVals(ini:fim);
    ValuesDetrend = detrend(tempVals, 'constant');
    Trend0(j:t) = ValoresLidos(j:t) - ValuesDetrend;
    ValoresLidos_noTrend0(j:t) = ValoresLidos(j:t) - Trend0(j:t);
    
    %Tendencia grau 1
    ValuesDetrend = detrend(tempVals);
    Trend1(j:t) = ValoresLidos(j:t) - ValuesDetrend;
    ValoresLidos_noTrend1(j:t) = ValoresLidos(j:t) - Trend1(j:t);
    
    %Tendencia grau 2
    polyfValues = polyfit(Tv, tempVals, 2);
    polyvValues(j:t) = polyval(polyfValues, Tv);
    ValoresLidos_noTrend2(j:t) = ValoresLidos(j:t) - polyvValues(j:t);

    % disp(j)
    j = j +30;
end

n = length(ValoresLidos);
Tm = 0:n-1;

%Apresenta graficos das tendencias

figure(1)
subplot(3,1,1);
plot(ValoresLidos);
title('Valores lidos');
subplot(3,1,2);
plot(Trend0);
title('Tendencia de grau 0');
subplot(3,1,3);
plot(ValoresLidos_noTrend0);
title('Valores lidos sem tendencia grau 0')

figure(2)
subplot(3,1,1);
plot(ValoresLidos);
title('Valores lidos');
subplot(3,1,2);
plot(Trend1);
title('Tendencia de grau 1');
subplot(3,1,3);
plot(ValoresLidos_noTrend1);
title('Valores lidos sem tendencia grau 1')

figure(3)
subplot(3,1,1);
plot(ValoresLidos);
title('Valores lidos');
subplot(3,1,2);
plot(polyvValues);
title('Tendencia de grau 2');
subplot(3,1,3);
plot(ValoresLidos_noTrend2);
title('Valores lidos sem tendencia grau 2')
