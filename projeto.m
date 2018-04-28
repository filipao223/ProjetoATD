clc

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

% figure(1)
% subplot(3,1,1);
% plot(ValoresLidos);
% title('Valores lidos');
% subplot(3,1,2);
% plot(Trend0);
% title('Tendencia');
% subplot(3,1,3);
% plot(ValoresLidos_noTrend0);
% title('Valores lidos sem tendencia grau 0')

% figure(2)
% subplot(3,1,1);
% plot(ValoresLidos);
% title('Valores lidos');
% subplot(3,1,2);
% plot(Trend1);
% title('Tendencia grau 1');
% subplot(3,1,3);
% plot(ValoresLidos_noTrend1);
% title('Valores lidos sem tendencia grau 1')

% figure(3)
% subplot(3,1,1);
% plot(ValoresLidos);
% title('Valores lidos');
% subplot(3,1,2);
% plot(polyvValues);
% title('Tendencia grau 2');
% subplot(3,1,3);
% plot(ValoresLidos_noTrend2);
% title('Valores lidos sem tendencia grau 2')

%Sazonalidade
ValoresLidos_semSazo = [];
ValoresSazonalidade = [];

j=1;
for t=30:30:length(ValoresLidos_noTrend2)
    if(length(ValoresLidos_noTrend2) - t <30)
        break
    end
    h0 = repmat((1:30).',1,1);
    sX = dummyvar(h0);
    BS = sX(1:30)\ValoresLidos_noTrend2(j:j+30);
    ST = sX(1:30)*BS;
    ValoresSazonalidade(j:j+30) = ST.';
    ValoresLidos_semSazo(j:j+30) = ValoresLidos(j:j+30) - (ST.');
    j = j+30;
end

%Grafico Sazonal
% figure(4)
% subplot(2,1,1);
% plot(ValoresSazonalidade);
% title('Original sem Sazonalidade');
% subplot(2,1,2);
% plot(ValoresLidos_semSazo);
% title('Sazonalidade');

%Grafico irreguralidade
% figure(5)
% subplot(2,1,1);
% plot(ValoresLidos(1:331).' - ValoresSazonalidade - ValoresLidos_noTrend2(1:331))
% title('Componente irregular')
% subplot(2,1,2);
% plot(ValoresSazonalidade + polyvValues(1:331).');
% title('Original sem irreguralidade');

%Verifica estacionaridade das series

check = 0;
for t=1:30:length(ValoresSazonalidade)-30
    h = adftest(ValoresSazonalidade(t:t+30));
    if(h ~= 1)
        disp('Componente sazonal Não Estacionária')
        check = 1;
        break
    end
    j=j+30;
end

if(check==0)
    disp('Componente sazonal Estacionária')
end

check = 0;
for t=1:30:length(ValoresLidos_semSazo)-30
    h = adftest(ValoresLidos_semSazo(t:t+30));
    if(h ~= 1)
        disp('Componente regularizada Não Estacionária')
        check = 1;
        break
    end
    j=j+30;
end

if(check==0)
    disp('Componente regularizada Estacionária')
end

FAC = autocorr(ValoresSazonalidade);
FACP = parcorr(ValoresSazonalidade);

% figure(6)
% subplot(2,1,1);
% plot(FAC);
% title('FAC');
% subplot(2,1,2);
% plot(FACP);
% title('FACP');

iddata_var = iddata(ValoresSazonalidade.', [], 1, 'TimeUnit', 'days');

%MODELO AR
% % naAR = 20;
% % opt = arOptions('Approach', 'ls');
% % modelo = ar(iddata_var, 30, opt);
% % 
% % polyCoef = polydata(modelo);
% % 
% % arValues = ValoresSazonalidade;
% % 
% % for t=naAR+1:365
% %   arValues(t)=sum(-polyCoef(2:end)'.* flip(arValues(t-naAR: t-1)));
% % end
% % 
% % ValoresLidosAR=repmat(arValues,2,1);
% % 
% % %Simulação do modelo AR com forecast
% % arValuesFinal=forecast(modelo,ValoresSazonalidade(1:naAR),365-naAR);
% % arValuesFinal2=repmat([ValoresSazonalidade(1:naAR); arValuesFinal],2,1);
% % 
% % figure(7)
% % plot(t,ValoresSazonalidade,'-+',t,ValoresLidosAR,'-o',t,arValuesFinal2,'-*');
% % title('Componente sazonal e estimação com modelo AR');

% % %Modelo ARMA
% % optARMAX = armaxOptions('SearchMethod', 'auto');
% % naARMA=5;
% % ncARMA=1;
% % modeloARMA = armax(iddata_var,[naARMA ncARMA], optARMAX);
% % [paARMA,pbARMA,pcARMA] = polydata(modeloARMA);
% % 
% % ruido = randn(365,1); %ruído branco
% % 
% % arValues = ValoresSazonalidade;
% % 
% % for k=naARMA+1:365
% %     arValues(k)=sum(-paARMA(2:end)'.*flip(arValues(k-naARMA:k)))+sum(pcARMA'.*flip(ruido(k-ncARMA:k)));
% % end
% % valoresLidosARMA=repmat(arValues,2,1);
% % 
% % %Simulação do modelo arma com forecast
% % armaValuesFinal=forecast(modeloARMA, ValoresSazonalidade(1:naARMA),365-naARMA);
% % armaValuesFinal2=repmat([ValoresSazonalidade(1:na1_ARMA); armaValuesFinal],2,1);
% % 
% % figure(5)
% % plot(t,ValoresSazonalidade,'-+',t,valoresLidosARMA,'-o',t,armaValuesFinal2,'-*');
% % title('Componente sazonal e estimação com o modelo ARMA');


%Modelo ARIMA

p= 5;
D= 1;
q= 1;

modeloARIMA = arima(p1, D1, q1);
estARIMA = estimate(modeloARIMA,ValoresLidos(1:365), 'Y0', ValoresLidos(1:p+1));

simARIMA = simulate(estARIMA,365*2);

figure(8)
plot(simARIMA);
title('Simulação com o modelo ARIMA')