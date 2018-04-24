

[A B] = importfile('dataset_ATD_PL2.csv');

Ar = A(:);
Br = B(:);

indA = find(isnan(A));
indB = find(isnan(B));

tempA = 0:length(A);
tempB = 0:length(B);

for k=1:length(indA)
    ttempA = (indA(k)-4:indA(k)-1);
    xtempA = Ar(indA(k)-4:indA(k)-1);
    Ar(indA(k)) = interp1(ttempA, xtempA, tempA(indA(k)), 'pchip', 'extrap');
end

for k=1:length(indB)
    ttempB = (indB(k)-4:indB(k)-1);
    xtempB = Br(indB(k)-4:indB(k)-1);
    Br(indB(k)) = interp1(ttempB, xtempB, tempB(indB(k)), 'pchip', 'extrap');
end

figure(2)
plot(Ar,'b')
hold on
plot(Br,'r')
hold off
title('\color{blue}A   \color{red}B')

Mb = mean(Br);
Ma = mean(Ar);

Sb = std(Br);
Sa = std(Ar);

R = corrcoef(Ar,Br);

MeanBr = repmat(Mb,length(Br),1);
MeanAr = repmat(Ma,length(Br),1);

SigmaBr = repmat(Sb,length(Br),1);
SigmaAr = repmat(Sa,length(Ar),1);

ind3 = find(abs(Br - MeanBr)>3*SigmaBr);
ind4 = find(abs(Ar - MeanAr)>3*SigmaAr);

for k=1:1:length(ind3)
    if(Br(ind3(k)) > Mb + 3*Sb)
        Br(ind3(k)) = Mb + 2.5*Sb;
    end
    if(Br(ind3(k)) < Mb - 3*Sb)
        Br(ind3(k)) = Mb - 2.5*Sb;    
    end      
end

for k=1:1:length(ind4)
    if(Ar(ind4(k)) > Ma + 3*Sa)
        Ar(ind4(k)) = Ma + 2.5*Sa;
    end
    if(Ar(ind4(k)) < Ma - 3*Sa)
        Ar(ind4(k)) = Ma - 2.5*Sa;    
    end      
end

ta=(0:length(Ar)-1)';
tb=(0:length(Br)-1)';


Ar_ro_to = detrend(Ar,'constant');
Br_ro_to = detrend(Br,'constant');

%figure(1)
%subplot(2,1,1);
%plot(ta,Ar,'-+',ta,Ar - Ar_ro_to,'-*');

pa = polyfit(ta,Ar,2);
pb = polyfit(tb,Br,2);

ta_2 = polyval(pa,ta);
tb_2 = polyval(pb,tb);

Ar_ro_to = Ar - ta_2;
Br_ro_to = Br - tb_2;

figure(1)
subplot(2,1,1);
plot(ta,Ar,'-+',ta,ta_2,'-*');

%figure(1)
%subplot(2,1,1);
%plot(ta,Ar,'-+',ta,ta_2,'-*');

