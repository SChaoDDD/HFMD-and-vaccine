clc
clear
close all
global vaccase y0 ev_12 pp1 pp2
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
k_pre1=readtable('D1.csv');
k_pre1=table2array(k_pre1);
days = 1:7:360*7;
pp1 = spline(days, k_pre1);
k_pre2=readtable('D2.csv');
k_pre2=table2array(k_pre2);
pp2 = spline(days, k_pre2);
phi1=1.01;
x0=[phi1,0.01,105,800,0.004,0.65];
y0=[y_0(1) 0 y_0(2) y_0(3) y_0(4) y_0(5) y_0(6) y_0(7) y_0(8) y_0(9) y_0(10) y_0(11) y_0(12) x0(5) y_0(13) y_0(14) y_0(15) 0];
preweek=1860;
tend=preweek*7;
options = odeset('RelTol',1e-12,'AbsTol',1e-12);
sol_e= ode45(@model_part,[0 tend],y0,options,x0);  
x1=0:1:preweek*7; %按周为一个时间单位
y1=deval(sol_e,x1);
%%绘图2017-01-01到2023-12-28
ttend=preweek*7;
h2=y1(15,2:ttend+1)-y1(15,1:ttend);
h3=y1(16,2:ttend+1)-y1(16,1:ttend);
h4=y1(18,2:ttend+1)-y1(18,1:ttend);
% x_t=y1(14,1:2550);
% save('xt.mat','x_t')

vac_week=day_2_week(h4,preweek);
data_week=day_2_week(vaccase(1:2520),360);
ev_week=day_2_week(h2,preweek);
evdata_week=day_2_week(ev_12(1:2520),360);
CVdata=day_2_week(cox_12(1:2520),360);
CVweek=day_2_week(h3,preweek);
% plot(y1(1,:))
% figure(1)
% plot(data_week,'*')
% hold on
% plot(vac_week)
% xlabel('Week')
% ylabel('Vaccine cases')
% figure(2)
% plot(evdata_week,'*')
% hold on
% plot(ev_week)
% xlabel('Week')
% ylabel('EV71 cases')
% figure(3)
% plot(CVweek)
figure(1)
plot(vac_week(360:end))
xlabel('Week')
ylabel('Vaccine cases')
figure(2)
plot(ev_week(360:end))
xlabel('Week')
ylabel('EV71 cases')
figure(3)
plot(CVweek)
xlabel('Week')
ylabel('NEV71 cases')
% week1 = 1:360;
% startYear = 2017;
% startWeek = 1;
% startDate = datetime(startYear, 1, 1) + calweeks(startWeek - 1);
% date1 = startDate + calweeks(week1 - 1);
% figure(1)
% plot(date1,vac_week(1:360),'-','LineWidth',2,'Color',[0.29,0.61,0.75])
% hold on
% plot(date1,data_week,'.','MarkerSize',22,'Color',[0.97,0.53,0.47])
% ylabel('Vaccination number')
% xlabel('Year')
% legend('Fitting curve','Data')
% xtickformat('yyyy')
% figure(2)
% plot(date1,ev_week(1:360),'-','LineWidth',2,'Color',[0.29,0.61,0.75])
% hold on
% plot(date1,evdata_week,'.','MarkerSize',22,'Color',[0.97,0.53,0.47])
% ylabel('Vaccination number')
% xlabel('Year')
% legend('Fitting curve','Data')
% xtickformat('yyyy')
% figure(3)
% plot(date1,CVweek(1:360),'-','LineWidth',2,'Color',[0.29,0.61,0.75])
% hold on
% plot(date1,CVdata,'.','MarkerSize',22,'Color',[0.97,0.53,0.47])
% ylabel('Vaccination number')
% xlabel('Year')
% legend('Fitting curve','Data')
% xtickformat('yyyy')
% save('Scenari4ev.mat','ev_week')