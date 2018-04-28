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

opt = arOptions('Approach', 'ls');
modelo = ar(iddata_var, 30, opt);

polyCoef = polydata(modelo);

arValues = ValoresLidos;

for t=31:365
  arValues(t)=sum(-polycoef(2:end)'.* flip(arValues(t-30: t-1)));
end

%----------------------CODIGO ROUBADO________________________


%---------Ex 1.6-------------
%Simulação do modelo AR
y1_AR = y1(1:na1_AR);
for k=na1_AR+1:24,
    y1_AR(k)=sum(-pcoef1_AR(2:end)'.*flip(y1_AR(k-na1_AR:k-1)));
end
y1_AR2=repmat(y1_AR,2,1);

%Simulação do modelo AR com forecast
y1_ARf=forecast(model1_AR,y1(1:na1_AR),24-na1_AR);
y1_ARf2=repmat([y1(1:na1_AR); y1_ARf],2,1);

%----------Ex 1.7------------
figure(2)
plot(t,st1,'-+',t,y1_AR2,'-o',t,y1_ARf2,'-*');
xlabel('t [h]');
title('Componente sazonal 1 (-+) e estimação com modelo AR');

figure(3)
plot(t, x1r ,'-+',t,y1_AR2, tr1_2,'-o');
xlabel('t [h]');
title('Série 1(-+) e estimação com o modelo AR(-o)');

%Métrica para análise
E1_AR=sum((x1r-(y1_AR2+tr1_2)).^2)

%----------Ex 1.8-------------
tr1_2_2=polyval(p1,tt); %Calcula tendência para 2N

figure(4)
plot(t,x1ro,'-+',tt,repmat(y1_AR2,2,1)+tr1_2_2,'-o');
xlabel('t [h]');
title('Série 1 (-+) e Previsão com o modelo AR (-o)');

%----------Ex 1.9-------------
% Estimação de um modelo arma

opt1_ARMAX = armaxOptions('SearchMethod', 'auto');
na1_ARMA=5;
nc1_ARMA=1;
model1_ARMA = armax(id_y1,[na1_ARMA nc1_ARMA], opt1_ARMAX);
[pa1_ARMA,pb1_ARMA,pc1_ARMA] = polydata(model1_ARMA);

%----------Ex 1.10------------
e = randn(24,1); %ruído branco

y1_ARMA = y1(1:na1_ARMA);
for k=na1_ARMA+1:24,
    y1_ARMA(k)=sum(-pa1_ARMA(2:end)'.*flip(y1_ARMA(k-na1_ARMA:k1)))+sum(pc1_ARMA'.*flip(e(k-nc1_ARMA:k)));
end
y1_ARMA2=repmat(y1_ARMA,2,1);

%Simulação do modelo arma com forecast
y1_ARMAf=forecast(model1_ARMA, y1(1:na1_ARMA),24-na1_ARMA);
y1_ARMAf2=repmat([y1(1:na1_ARMA); y1_ARMAf],2,1);

%-----------Ex 1.11------------
figure(5) %compara a componente sazonal com a sua estimação
plot(t,st1,'-+',t,y1_ARMA2,'-o',t,y1_ARMAf2,'-*');
xlabel('t [h]');
title('Componente sazonal 1(-+) e estimação com o modelo ARMA');

figure(6) %compara a série com o modelo ARMA + tendência
plot(t,x1r,'-+',t,y1_ARMA2+tr1_2,'-o');
xlabel('t [h]');
title('Série 1 (-+) e estimação com o modelo ARMA(-o)')

%Métrica para análise
E1_ARMA = sum((x1r-y1_ARMA2(1:N)).^2)

%-----------Ex 1.12------------
figure(7) %Faz a previsão para 2N
plot(t,x1r,'-+',tt,repmat(y1_ARMA2,2,1)+tr1_2_2, '-o');
xlabel('t [h]');
title('Série 1(-+) e previsão com o modelo ARMA(-o)')

%-----------Ex 1.13-------------
%Estimação de um modelo ARIMA
EstMd1 = estimate(Md,x1r(1:N), 'Y0', x1r(1:p1_ARIMA+1));

%-----------Ex 1.14-------------
%Simulação do modelo ARIMA
y1_ARIMA = simulate(EstMd1,N);

%-----------Ex 1.15-------------
figure(8) %compara a serie com a sua estimaçao
plot(t,x1r,'-+',t,y1_ARIMA,'-o');
xlabel('t [h]');
title('Série 1(-+) e estimação com o modelo ARIMA(-o)')

%métrica para análise
E1_ARIMA=sum((x1r-y1_ARIMA(1:N)).^2)

%-----------Ex 1.16--------------
%Simulação do modelo ARIMA para 2N
y1_ARIMA2 = simulate(EstMd1,2*N);

figure(9) %faz a previsão para 2N
plot(t,x1r,'-+',tt,y1_ARIMA2,'-o');
xlabel('t [h]');
title('Série 1(-+) e estimação com o modelo ARIMA(-o)')
