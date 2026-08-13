clc
clear
close all
global vaccase y0 ev_12

vac=load('totalvac.mat');
vaccase=vac.v;

%%初值及其范围
phi1=1.01;
x0=[phi1,0.01,105,800,0.006,0.6,0.89];%初值为0.006
y0=[y_0(1) 0 y_0(2) y_0(3) y_0(4) y_0(5) y_0(6) y_0(7) y_0(8) y_0(9) y_0(10) y_0(11) y_0(12) x0(5) y_0(13) y_0(14) y_0(15) 0];
param_l=[0,0.005,0,500,0,0,0];
param_r=[10,1,1000,1000,1,0.5,1];

%%优化部分
options=optimset('Display','on','MaxIter', 5000, 'MaxFunEvals',3000);
[x_e,fval]=fmincon(@targetfun_1,x0,[],[],[],[],param_l,param_r,[],options);
y00=y0;
y00(14)=x_e(5);

%%求解ODE
tend=5000;
options = odeset('RelTol',1e-12,'AbsTol',1e-12);
sol_e= ode45(@model_part,[0 tend],y00,options,x_e);  
x1=0:1:tend; %按周为一个时间单位
y1=deval(sol_e,x1);

%%绘图2017-01-01到2023-12-28
ttend=2553;
h2=y1(15,2:ttend+1)-y1(15,1:ttend);
h3=y1(16,2:ttend+1)-y1(16,1:ttend);
h4=y1(18,2:ttend+1)-y1(18,1:ttend);
h1=h2+h3;
t_vac=datetime(2017,1,1):days(1):datetime(2023,12,28);
figure(1)
plot(t_vac,h4,'b');
hold on
plot(t_vac,vaccase(1:2553),'r*')
figure(2)
plot(t_vac,h2,'b-')
hold on
plot(t_vac,ev_12,'r*')
ylabel('EV71')
xtickformat('yyyy')

