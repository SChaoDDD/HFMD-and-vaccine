using Lux, DiffEqFlux, DifferentialEquations, Optimization, OptimizationOptimJL, Random, Plots
using DataFrames
using CSV
using ComponentArrays
using OptimizationOptimisers
rng = Random.default_rng()
Random.seed!(14)

source_data = DataFrame(CSV.File("C:/Users/XLYC/Desktop/test/juliacode/expvac.csv"))
vac_data = source_data[1:2520, 2]  # 原始每日数据
cum_vac = cumsum(vac_data)

# 将每日数据聚合为每周数据（每7天求和）
function aggregate_to_weekly(daily_data)
    n_weeks = div(length(daily_data), 7)
    weekly_data = zeros(Float32, n_weeks)
    
    for i in 1:n_weeks
        start_idx = (i-1) * 7 + 1
        end_idx = i * 7
        weekly_data[i] = daily_data[end_idx]  # 取每周最后一天的累计值
    end
    
    return weekly_data
end

trainingdata_1 = aggregate_to_weekly(cum_vac)  # 每周累计接种数据

w=2*pi/365;
wa=pi/365;
nu=0.002;
aa=1/10;
ab=1/10;
gammaa=0.1;
gammab=0.1;
mu=0.00017;
Gamma=1054;

function beta1(t)
    w1 = π / 365
    return 0.01065 * (1.7 * sin(t * 2 * w1 + π * (182 / 365) - 75 * 2 * w1) +
                      3.5 * sin(t * 2 * 2 * w1 - 75 * w1 * 2) +
                      cos(t * w1 - 70 * w1 - 20 * w1 - π) +
                      2 * sin(t * 2 * w1 - 40 * w1) +
                      3 * sin(4 * t * w1 - 280 * w1) + 10)
end

function beta2(t)
    w = 2 * π / 365
    return 0.0578 * (0.38 * (1.7 * sin(t * w + π * (182 / 365) - 75 * w) +
                             3.5 * sin(t * 2 * w - 75 * w) + 5))
end

ann = Lux.Chain(Lux.Dense(1, 64, tanh),Lux.Dense(64,64, tanh),Lux.Dense(64, 32, tanh),Lux.Dense(32, 1, softplus))
p_0, st = Lux.setup(rng, ann)
function SEIR_nn(du, u, p, t)
    S, V, Ea, Eb, Ia, Ib, Sa, Sb, Fa, Fb, Ja, Jb, R, x, N, C, Vac = u
    betaa = beta1(t);
    betab = beta2(t);
    betav1 = 0.65*betaa;
    D1 = max(500*(((ann([t], p, st))[1])[1])+10,0);
    #D2 = max(500*(((ann([t], p, st))[1])[2])+10,0);
    #s = max(500*(((ann([t], p, st))[1])[2])+10,0);
    du[1] = Gamma - 0.009*max(x,0)*S - betaa*S*(Ia+Ja)/N - betab*S*(Ib+Jb)/N - mu*S + nu*(Sa+Sb+R); #+ V/800;
    du[2] = 0.009*max(x,0)*S - betav1*V*(Ia+Ja)/N - betab*V*(Ib+Jb)/N - mu*V;# - V/800;
    du[3] = betaa*S*(Ia+Ja)/N + betav1*V*(Ia+Ja)/N - aa*Ea - mu*Ea;
    du[4] = betab*S*(Ib+Jb)/N + betab*V*(Ib+Jb)/N - ab*Eb - mu*Eb;
    du[5] = aa*Ea - gammaa*Ia - mu*Ia;
    du[6] = ab*Eb - gammab*Ib - mu*Ib;
    du[7] = gammab*Ib - betaa*Sa*(Ia+Ja)/N - mu*Sa - nu*Sa;
    du[8] = gammaa*Ia - betab*Sb*(Ib+Jb)/N - mu*Sb - nu*Sb;
    du[9] = betaa*Sa*(Ia+Ja)/N - aa*Fa - mu*Fa;
    du[10] = betab*Sb*(Ib+Jb)/N - ab*Fb - mu*Fb;
    du[11] = aa*Fa - gammaa*Ja - mu*Ja;
    du[12] = ab*Fb - gammab*Jb - mu*Jb;
    du[13] = gammaa*Ja + gammab*Jb - mu*R - nu*R;
    du[14] = -0.009 * x * (1 - x) + x*(1 - x)*(D1*(Ib+Jb))/N-(nu*(Sa+Sb+R))*x/S;
    du[15] = Gamma - mu*N;
    du[16] = aa*Ea + aa*Fa;
    du[17] = 0.009*max(x,0)*S;
end

u0 = Float32[5621064,6,235,135,367,210,46308,39378,2,1,3,2,617,0.004,5708324,24,6]
tspan = (0.0f0, 2520.0f0)  # 保持原来的时间跨度（天数）

# 修改为每周时间步长：每7天一个数据点
n_weeks = length(trainingdata_1)
tsteps = Float32.(0:7:(n_weeks-1)*7)  # 每7天一个时间点
prob_neuralode = ODEProblem(SEIR_nn, u0, tspan, ComponentArray(p_0))

function predict_neuralode(θ)
    prob = remake(prob_neuralode, p=θ)
    sol = Array(solve(prob, Tsit5(), saveat=tsteps))
    x = sol[14, :]
    C = sol[16, :]
    D = zeros(Float32, length(C))
    Vac = sol[17, :]
    return C, D, Vac
end

# 测试预测函数
pred_test = predict_neuralode(p_0)
println("预测数据长度: ", length(pred_test[3]))
println("真实数据长度: ", length(trainingdata_1))

function loss_neuralode(p)
    pred = predict_neuralode(p)
    pred_vac = pred[3][1:length(trainingdata_1)]  # 确保长度一致
    train=diff(trainingdata_1)
    train1=train./maximum(train)
    pre=diff(pred_vac)
    pre1=pre./maximum(train)
    eps = 1e-8
    loss1 = sum(abs2, ((train1[1:150]) .- (pre1[1:150])))+5*sum(abs2, ((train1[150:359]) .- (pre1[150:359])))
    
    return loss1
end

# 测试损失函数
println("初始损失: ", loss_neuralode(p_0))

pinit = ComponentArray(p_0)
adtype = Optimization.AutoZygote()
optf = Optimization.OptimizationFunction((x, p) -> loss_neuralode(x), adtype)
optprob = Optimization.OptimizationProblem(optf, pinit)

loss_history = Float32[]
callback = function (θ, l)
    push!(loss_history, l)
    if length(loss_history) % 500== 0
        println("Iteration: ", length(loss_history), " Loss: ", l)
        display(plot(loss_history, label="Loss", xlabel="Iteration", ylabel="Loss", lw=2))
    end
    return false
end

# 第一阶段优化
result_neuralode = Optimization.solve(optprob,
    OptimizationOptimisers.ADAM(0.001),
    maxiters=3500,
    callback=callback)

# 第二阶段优化
optprob2 = remake(optprob, u0=result_neuralode.u)
result_neuralode_final = Optimization.solve(optprob2,
    Optim.LBFGS(),
    allow_f_increases=false)

pfinal = result_neuralode_final.u

# 最终预测
pred = predict_neuralode(pfinal)

# 绘制结果对比
plt1 = scatter(tsteps[1:length(trainingdata_1)], trainingdata_1, label="Real", markersize=2)
plot!(plt1, tsteps[1:length(trainingdata_1)], pred[3][1:length(trainingdata_1)], 
      label="Fit", linewidth=2)
xlabel!(plt1, "DAY")
ylabel!(plt1, "CASES")
title!(plt1, "Fit (Weekly Data)")
display(plt1)

# 绘制神经网络学习到的参数
beta_nn = zeros(Float32, length(trainingdata_1))
println("神经网络学习到的beta参数:")
for i in 1:length(trainingdata_1)
    t = tsteps[i]
    beta_nn[i] = 500*(ann([t], pfinal, st)[1][1])+10
end

plt2 = plot(tsteps[1:length(trainingdata_1)], beta_nn, label="k", linewidth=2)
xlabel!(plt2, "DAY")
ylabel!(plt2, "k")
title!(plt2, "k(t) - Weekly")
display(plt2)

plt3 = scatter(tsteps[1:length(trainingdata_1)-1], diff(trainingdata_1), label="Real", markersize=2)
plot!(plt3, tsteps[1:length(trainingdata_1)-1], diff(pred[3][1:length(trainingdata_1)]), 
      label="Fit", linewidth=2)
xlabel!(plt3, "DAY")
ylabel!(plt3, "CASES")
title!(plt3, "Weekly Difference Fit")
display(plt3)
#cases = diff(pred[3][1:length(trainingdata_1)])
#data = DataFrame("FitCases" => cases)

#CSV.write("C:/Users/XLYC/Desktop/test/juliacode/k1cases拟合无疫苗失效.csv", data)
#data = DataFrame(
#    D = beta_nn
#)
#CSV.write("C:/Users/XLYC/Desktop/test/juliacode/k1cases拟合无疫苗失效.csv", data)