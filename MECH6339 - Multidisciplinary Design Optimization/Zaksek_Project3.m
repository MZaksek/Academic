% Matthew Zaksek
% MECH 6339 (Multidisciplinary Design Optimization)
% Project 3
% May 7, 2022

clc;
close all;
clear all;

% Define parameters
h = 0.5;    % Height/distance between hemispheres (m)
ri = 0.1;   % Internal radius (m)
Pi_target = 20684000;    % Target internal pressure (Pa)
fos = 1.2;  % Factor of safety, applied to target internal pressure
Pi = Pi_target; % Used internal pressure, no OUU (Pa)
sigma_x = 0.01; % Degree of variation for OUU reliability

% Material-Dependent Properties
% 1=AISI 4130 Steel, 2=Aluminun 6061
Sy = [460000000; 55150000]; % Pa
rho = [7850; 2700];    % kg/m^3
material_cost = [1101.06; 33.35];   % USD/kg

% Curve Fitting Function Coefficients (Material-Dependent)
p00 = [2.413e+08; 2.06e+07];
p10 = [36.43; 5.061];
p01 = [-8.906e+10; -8.543e+08];
p20 = [-1.522e-09; -4.213e-11];
p11 = [-3915; -42];
p02 = [9.366e+12; 1.011e+10];
p21 = [1.04e-07; 5.429e-11];
p12 = [1.275e+05; 148.2];
p03 = [-2.919e+14; -3.543e+10];

% x(1)=Wall Thickness (m)
x0 = [0.001];

A=[];
b=[];
Aeq=[];
beq=[];
lb = [0];
ub = [1];
nonlcon = @p3nonlcon;

% Define function to minimize; total volume of cylinder
fun = @(x)(h*pi*((ri+x(1))^2-ri^2)+4/3*pi*((ri+x(1))^3-ri^3));

% Initialize minimum cost as infinity
min_cost = inf;

% Perform optimization for each material; material with lowest cost is
% optimal
for i = 1:length(Sy)
    x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,@(x)p3nonlcon(x,Sy,p00,p10,p01,p20,p11,p02,p21,p12,p03,Pi,i));
    volume(i) = (h*pi*((ri+x(1))^2-ri^2)+4/3*pi*((ri+x(1))^3-ri^3));
    price(i) = volume(i) * rho(i) * material_cost(i);
    
    if price(i) < min_cost
        x_opt = x;
        min_cost = price(i);
        material_index = i;
    end
end

x_opt
min_cost
material_index

% Reliability, without OUU
nsamples = 10000;
failures = 0;
for i = 1:nsamples
    x = x_opt + sigma_x .* randn(1,1);
    const_matrix = [p00(material_index) + p10(material_index)*Pi + p01(material_index)*x(1) + p20(material_index)*Pi^2 + p11(material_index)*Pi*x(1) + p02(material_index)*x(1)^2 + p21(material_index)*Pi^2*x(1) + p12(material_index)*Pi*x(1)^2 + p03(material_index)*x(1)^3 - Sy(material_index);
        -x(1)];
    
    if any (const_matrix > 0)
        failures = failures + 1;
    end
end

failures
R_est = (nsamples - failures)/nsamples

Pi = Pi_target*fos; % Used internal pressure, WITH Factor of Safety/OUU (Pa)

% Initialize minimum cost as infinity
min_cost = inf;

for i = 1:length(Sy)
    x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,@(x)p3nonlcon(x,Sy,p00,p10,p01,p20,p11,p02,p21,p12,p03,Pi,i));
    volume(i) = (h*pi*((ri+x(1))^2-ri^2)+4/3*pi*((ri+x(1))^3-ri^3));
    price(i) = volume(i) * rho(i) * material_cost(i);
    
    if price(i) < min_cost
        x_opt = x;
        min_cost = price(i);
        material_index = i;
    end
end

x_opt
min_cost
material_index

% Reliability, WITH OUU
nsamples = 10000;
failures = 0;
for i = 1:nsamples
    x = x_opt + sigma_x .* randn(1,1);
    const_matrix = [p00(material_index) + p10(material_index)*Pi_target + p01(material_index)*x(1) + p20(material_index)*Pi_target^2 + p11(material_index)*Pi_target*x(1) + p02(material_index)*x(1)^2 + p21(material_index)*Pi_target^2*x(1) + p12(material_index)*Pi_target*x(1)^2 + p03(material_index)*x(1)^3 - Sy(material_index);
        -x(1)];
    
    if any (const_matrix > 0)
        failures = failures + 1;
    end
end

failures
R_est = (nsamples - failures)/nsamples


% Nonlinear constraint function
function [c,ceq] = p3nonlcon(x,yield_strength,p00,p10,p01,p20,p11,p02,p21,p12,p03,Pi,i)

    c = [p00(i) + p10(i)*Pi + p01(i)*x(1) + p20(i)*Pi^2 + p11(i)*Pi*x(1) + p02(i)*x(1)^2 + p21(i)*Pi^2*x(1) + p12(i)*Pi*x(1)^2 + p03(i)*x(1)^3 - yield_strength(i)];
    ceq = [];
        
end