function f=targetfun_1(x)  %x是待估计未知参数向量

global vaccase  y0 ev_12

options = odeset('RelTol',1e-10,'AbsTol',1e-10);
tend=2600;
y00=y0;
y00(14)=x(5);
sol= ode45(@model_part,[0 tend],y00,options,x);  %数值求解微分方程模型，时间区间为0到1095
x1=0:1:tend; %按天为一个时间单位
y1=deval(sol,x1);
sol0=(y1(18,2:2554)-y1(18,1:2553))';
sol2=(y1(16,2:2554)-y1(16,1:2553))';
f1=sol0-vaccase(1:2553);
f3=sol2-ev_12(1:2553);
% f=norm(f3)+1.5*norm(f1);
f=norm(f1);
end
