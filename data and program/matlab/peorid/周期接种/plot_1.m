clc
clear
close all
global vaccase y0 ev_12
tstart=3289;ten=5841;
case_n=xlsread('everyday.xlsx');
case_number=case_n(tstart:ten);  
cox=load('qita.mat');
ev=load('ev.mat');
cox=cox.b0;
ev=ev.b1;
cox_12=cox(tstart:ten);
ev_12=ev(tstart:ten);
vac=load('totalvac.mat');
vaccase=vac.v;


y_0=load('xend_1.mat');
y_0=y_0.xend;
% phi1=10.6e-6;
% x0=[phi1,0.01,1,700,0.0019,0.7];
phi1=1.01;
x0=[phi1,0.01,105,800,0.004,0.65,0.88];%初值为0.006
% x0=[0.0504,0.005,1000,1000,0.0076,0.5];%
% x0=[phi1,0.0098,68,800,0.0015,0.5];%初值为0.006
y0=[y_0(1) 0 y_0(2) y_0(3) y_0(4) y_0(5) y_0(6) y_0(7) y_0(8) y_0(9) y_0(10) y_0(11) y_0(12) x0(5) y_0(13) y_0(14) y_0(15) 0];
preweek=1860;
tend=preweek*7;
options = odeset('RelTol',1e-12,'AbsTol',1e-12);
sol_e= ode45(@model_part,[0 tend],y0,options,x0);  
x1=0:1:tend; %按天为单位
y1=deval(sol_e,x1);
%%绘图2017-01-01到2023-12-28
ttend=tend;
h2=y1(15,2:ttend+1)-y1(15,1:ttend);
h3=y1(16,2:ttend+1)-y1(16,1:ttend);
h4=y1(18,2:ttend+1)-y1(18,1:ttend);
vac_week=day_2_week(h4,preweek);
ev_week=day_2_week(h2,preweek);
CVweek=day_2_week(h3,preweek);
realvac=day_2_week(vaccase(1:2520),360);
evdata_week=day_2_week(ev_12(1:2520),360);
cvdata_week=day_2_week(cox_12(1:2520),360);
h5=y1(1,1:2520);
h6=y1(2,1:2520);
h7=y1(17,1:2520);
plot(h5)
% save('N_p','h7')
% plot(realvac,'*')
% hold on 
% plot(vac_week)
% y=realvac;
% y1=vac_week;
% y_mean = mean(y);                  % 计算实际值的均值
% SS_res = sum((y- y1).^2);     % 残差平方和
% SS_tot = sum((y - y_mean).^2);     % 总平方和
% R_squared = 1 - (SS_res / SS_tot);     % R²计算公式AIC6589 BIC6793

figure(1)
plot(vac_week(361:end))
xlabel('Week')
ylabel('Vaccination number')
xlim([0 1300])
figure(2)
plot(ev_week(361:end))
xlabel('Week')
ylabel('EV71 cases')
xlim([0 1300])
figure(3)
plot(CVweek(361:end))
xlabel('Week')
ylabel('NEV71 cases')
xlim([0 1300])
real=day_2_week(case_number(1:2553),floor(2553/7));
model=day_2_week(h3+h2,364);
% save('periodvac.mat','vac_week')


% week1 = 1:360;
% startYear = 2017;
% startWeek = 1;
% startDate = datetime(startYear, 1, 1) + calweeks(startWeek - 1);
% date1 = startDate + calweeks(week1 - 1);
% figure(1)
% plot(date1,vac_week(1:360),'-','LineWidth',2,'Color',[0.29,0.61,0.75])
% hold on
% plot(date1,realvac(1:360),'.','MarkerSize',22,'Color',[0.97,0.53,0.47])
% ylabel('EV71 Vaccination')
% xlabel('Year')
% legend('Fitting curve','Data')
% xtickformat('yyyy')
% figure(2)
% plot(date1,ev_week,'-','LineWidth',2,'Color',[0.29,0.61,0.75])
% hold on
% plot(date1,evdata_week(1:360),'.','MarkerSize',22,'Color',[0.97,0.53,0.47])
% ylabel('HFMD Cases Caused by EV71')
% xlabel('Year')
% legend('Fitting curve','Data')
% xtickformat('yyyy')
% figure(3)
% plot(date1,CVweek(1:360),'-','LineWidth',2,'Color',[0.29,0.61,0.75])
% hold on
% plot(date1,cvdata_week(1:360),'.','MarkerSize',22,'Color',[0.97,0.53,0.47])
% ylabel('HFMD Cases Caused by Non-EV71')
% xlabel('Year')
% legend('Fitting curve','Data')
% xtickformat('yyyy')