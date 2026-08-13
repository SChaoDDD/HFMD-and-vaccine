k=readtable('D1.csv');
k=table2array(k);
k_pre=[];
k_pre(1)=k(end);
for i=2:1501
    % if 0.32806-0.0004*i>0
    k_pre(i)=k_pre(i-1)+(0.32806);
    % else 
    %      k_pre(i)=k_pre(i-1);
    % end
end
k_total=[k(1:end-1);k_pre'];
writematrix(k_total,'D_pre10year.csv')
% % 假设每周一个数据点，共 360 周
% weeks = 1:625;  % 周数
% data_weekly = k_total;  % 示例数据（每周一个点）
% % 假设每周一个数据点，共 360 周
% 
% % 将周数据转换为天数据
% days = 1:7:625*7;  % 每周的第一天
% data_daily = data_weekly;  % 每天的数据（每周一个点）
% 
% % 使用 spline 生成分段多项式
% pp = spline(days, data_daily);
% 
% % 定义需要插值的时间点（2520 天内的任意时间点）
% xx = 1:4375;
% 
% % 使用 ppval 计算插值点的值
% yy = ppval(pp, xx);
% 
% % 绘图
% figure;
% plot(days, data_daily, 'o', 'MarkerSize', 10, 'DisplayName', '原始数据');  % 原始数据点
% hold on;
% plot(xx, yy, '-', 'LineWidth', 2, 'DisplayName', '三次样条插值');  % 插值曲线
% xlabel('天数');
% ylabel('数据值');
% title('使用 ppval 实现三次样条插值');
% legend('show');
% grid on;
% grid on;