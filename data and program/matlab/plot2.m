%参数估计 从2018年7月开始用一年数据
clc
clear
close all
global case_number cox_12 ev_12 S0
%%
tstart=732;ten=3288;
case_n=xlsread('everyday.xlsx');
case_number=case_n(tstart:ten);  
cox=load('qita.mat');
ev=load('ev.mat');
cox=cox.b0;
ev=ev.b1;
cox_12=cox(tstart:ten);
ev_12=ev(tstart:ten);
S0=5439785;
%% 给一组初值看似合效果
%   I1为Ev71，I2为其他
% beta1=0.00007;beta2=0.00005;nu=1/30;a1=1/8;gamma=1/14;mu=0.01;S0=950;E10=35;E20=15;
% I10=24;I20=6;beta03=1.9;beta04=1.8;c1=0.3;c2=0.3;
% 
%  beta1=0.095;beta2=0.095;nu=1/300;a1=1/5;gamma=1/5;E10=50;E20=50;R0=10;
%  I10=15;I20=10;

%param=[beta1,beta2,nu,a1,gamma,mu,S0,E10,E20,beta03,beta04,c1,c2];
%param=[beta1,beta2,nu,a1,gamma,E10,E20 R0,I10,I20];
% x0=param;
x_0=load('xnew_8.mat');
x0=x_0.x_e;
x0(1)=0.01065;
x0(2)=0.0578;
E10=x0(6);
E20=x0(7);
R0=x0(8);
I10=270;
I20=x0(10);

% I10=450;
% I20=400;
N0=S0+E10+E20+I10+I20+9+7+6+5+6+6+R0;
tend=2587;

options = odeset('RelTol',1e-12,'AbsTol',1e-12);
%检验初始参数下模型与数据拟合结果
 % y0=[S0 E10 E20 I10 I20 9 7 6 5 6 6 R0 5 8 N0];
 y0=[S0 E10 E20 I10 I20 9 7 6 5 6 6 R0 0 0 N0];
  sol= ode45(@model_3,[0 tend],y0,options,x0); 


x1=0:1:2586; %按周为一个时间单位
y1=deval(sol,x1);
h1=y1(13,2:2557)-y1(13,1:2556)+y1(14,2:2557)-y1(14,1:2556);
h2=y1(13,2:2557)-y1(13,1:2556);
h3=y1(14,2:2557)-y1(14,1:2556);
%x2=1:1:1826;

plot(y1(5,:))
% coxweek=day_2_week(h1(1:2184),312);
% dataweek1=day_2_week(case_number(1:2184),312);
% y0=h1(1:2191);
% y01=case_number(1:2191)';
% y_mean = mean(y0);                  % 计算实际值的均值
% SS_res = sum((y0- y01).^2);     % 残差平方和
% SS_tot = sum((y0 - y_mean).^2);     % 总平方和
% R_squared = 1 - (SS_res / SS_tot);     % R²计算公式
% mape = mean(abs((y0 - y01) ./ y0)) * 100;
% smape = mean(2 * abs(y0 - y01) ./ (abs(y0) + abs(y01))) * 100;
% 
% plot(y0)
% hold on
% plot(y01,'*')





coxweek=day_2_week(h3(1:2556),365);
dataweek1=day_2_week(case_number(1:2556),365);
week1 = 1:365;
startYear = 2010;
startWeek = 1;
startDate = datetime(startYear, 1, 1) + calweeks(startWeek - 1);
date1 = startDate + calweeks(week1 - 1);
plot(date1,coxweek,'-','LineWidth',1.5)
hold on
plot(date1,dataweek1,'.','MarkerSize',15)
ylabel('NEV71 Cases')
xlabel('year')
legend('Fitting','Real Data')
xtickformat('yyyy')

%sum((coxweek-dataweek1).^2)