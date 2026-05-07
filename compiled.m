clc;
clear;
%run WastewaterParameters.m
%Dissolved Compounds

S_O2 = 2; %Dissolved Oxygen, gO2/m3
S_I = 30; %Soluble Inert; gCOD/m3
S_S = 600; %readily biodegradable substrates; gCOD/m3
S_NH4 = 16; %Ammonium; g N/m3
S_N2 = 0.0001; %Dinitrogen released by denitrification gN/m3
S_NOX = 2; %Nitrite + Nitrate gN/m3
S_ALK = 5; % Alkalintiy - Bicarbonate mole-HCO3/m3

%Particulate Compounds

X_I = 25; %Inert Particulate Organics g COD/m3
X_S = 115; %Slowly biodegradable substrates g COD/m3
X_H = 1000; %Heterotropic Biomass g COD/m3
X_STO = 50; %Organics stored by heterotrophs gCOD/m3 (0.001)
X_A = 200; %Autotropic Nitrifying Biomass; gCOD/m3
X_SS = 1250; %Total Suspended Solids g SS/m3





%To fix divide by 0 errors
% if X_H < 1e-6
%     X_H = 1e-6;
% end

%Inlet Parameters

X_in = [
0;      % S_O2 (usually ~0 in influent)
30;     % S_I
600;     % S_S
16;     % S_NH4
0;      % S_N2
2;      % S_NOX
5;      % S_ALK
25;     % X_I
115;    % X_S
30;     % X_H
0.001;  % X_STO
0.01;   % X_A
125     % X_SS
];


%For SRT Control
idx_soluble = [1 2 3 4 5 6 7];
idx_particulate = [8 9 10 11 12 13];

%run KineticParameters.m
%Kinetic Parameters (as example at 20 deg C)

%Hydrolysis
p.k_H = 1; %Hydrolysis rate constant (3)
p.K_X = 1; %Hydrolysis saturation constant

%Heterotropic Organisms X_H, Aerobic and Denitrifying Activity
p.k_STO = 5; %Storage rate constant
p.eta_NOX = 0.6; %Anoxic reduction factor
p.K_O2 = 0.2; %Saturation constant for S_O2
p.K_NOX = 0.5; %Saturation constant for S_NOX
p.K_S = 2; %Saturation constant for Substrate
p.K_STO = 0.1; %Saturation constant for X_STO (1)
p.mu_H = 6; %Heterotropic maximum growth rate of X_H (2)
p.K_NH4 = 0.01; %Satruation constant for Ammonium, S_NH4
p.K_ALK = 0.1; %Saturation constant for alkalinity for X_H
p.b_H_O2 = 0.02; %Aerobic Endogenous Respiration Rate of X_H (0.1)
p.b_H_NOX = 0.01; %Anoxic Endogenous Respiration rate of X_H (0.1)
p.b_STO_O2 = 0.2; %Aerobic respiration rate for X_STO
p.b_STO_NOX = 0.1;%Anoxic Respiration rate for X_STO

%Autotrophic organisms X_A, nitrifying activity
p.mu_A = 1; %Autotrophic max growth rate of X_A
p.K_A_NH4 = 1; %Ammonium substrate saturation for X_A
p.K_A_O2 = 0.5; %Oxygen saturation for nitrifiers
p.K_A_ALK = 0.5; %bicarbonate saturation for nitrifiers
p.b_A_O2 = 0.015; %Aerobic endogenous respiration rate of X_A (0.15)
p.b_A_NOX = 0.005; %Anoxic endogenous respiration rate of X_A (0.05)
p.K_A_NOX = 0.2;  %Nitrate saturation for nitrifiers endogenous respiration (Please check) 


%Aeration

p.kLa = 200;      % 1/day
p.S_sat = 8;    % g/m^3


%Continuous Reactor

p.Q = 100;     % m3/day
p.V = 700;      % m3
p.D = p.Q / p.V;   % dilution rate (day^-1)

p.SRT = 40;   % days


%run StoichCompParameters.m
f_S_I = 0; %production of S_I in hydrolysis
Y_STO_O2 = 0.85; %Aerobic Yield of Stored product per S_s
Y_STO_NOX = 0.80; %Anoxic Yield of Stored product per S_s
Y_H_O2 = 0.63; %Aerobic yield of heterotropic biomass
Y_H_NOX = 0.54; %Anoxic yield of heterotropic biomass
Y_A = 0.24; %Yield of autotropic biomass per NO3-N
f_X_I = 0.20; %production of X_I in endogenous respiration
i_N_S_I = 0.01; %N content of S_I
i_N_S_S = 0.03; %N content of S_S
i_N_X_I = 0.02; %N content of X_I
i_N_X_S = 0.04; %N content of X_S
i_N_BM = 0.03; %N content of Biomass , X_H, X_A (0.07)
i_SS_X_I = 0.75; %SS to COD ratio of X_I
i_SS_X_S = 0.75; %SS to COD ratio of X_S
i_SS_BM = 0.90; %SS to COD ratio of X_H, X_A

%run unknownSMParam.m

%Hydrolysis
x1 = 1- f_S_I;
y1 = i_N_X_S - x1*i_N_S_S - f_S_I*i_N_S_I;
z1 = y1/14;

%Aerobic Storage
x2 = Y_STO_O2 - 1;
y2 = i_N_S_S;
z2 = y2/14;
t2 = 0.6* Y_STO_O2;

%Anoxic Storage
x3 = (Y_STO_NOX -1)/(1.71+4.57);
y3 = i_N_S_S;
z3 = (y3/14) - (x3/14);
t3 = 0.6* Y_STO_NOX;

%Aerobic Growth of X_H
x4 = 1 - (1/Y_H_O2);
y4 = -i_N_BM;
z4 = y4/14;
t4 = i_SS_BM - (0.6/Y_H_O2);

%Anoxic Growth (denitrification)
x5 = (1 - (1/Y_H_NOX))/(4.57 - 1.71);
z5 = (y4/14) - (x5/14);
t5 = i_SS_BM - (0.6/Y_H_NOX);

%Aerobic Endogenous Respiration
x6 = f_X_I - 1;
y6 = i_N_BM - (f_X_I*i_N_X_I);
z6 = y6/14;
t6 = (f_X_I*i_SS_X_I) - i_SS_BM;

%Anoxic Endogenous Respiration
x7 = (f_X_I - 1)/(4.57-1.71);
y7 = i_N_BM - (f_X_I*i_N_X_I);
z7 = (y7/14) - (x7/14);
t7 = (f_X_I*i_SS_X_I) - i_SS_BM;

%Aerobic Respiration of X_STO
x8=-1;
t8 = -0.6;

%Anoxic Respiration of X_STO
x9 = -1/(4.57-1.71);
z9 = -x9/14;
t9 = -0.6;

%Aerobic Growth of X_A
x10 = 1- (4.57/Y_A);
y10 = -i_N_BM - (1/Y_A);
z10 = (y10/14) - (1/(14*Y_A));
t10 = i_SS_BM;

%Aerobic Endogenous Respiration
x11 = f_X_I - 1;
y11 = i_N_BM - (f_X_I*i_N_X_I);
z11 = y11/14;
t11 = (f_X_I*i_SS_X_I) - i_SS_BM;

%Anoxic Endogenous Respiration
x12 = (1 - f_X_I)/(1.71-4.57);
y12 = i_N_BM - (f_X_I*i_N_X_I);
z12 = (y12/14) - (x12/14);
t12 = (f_X_I*i_SS_X_I) - i_SS_BM;


%run stoichiometricMatrix.m


%Composition Matrix Definition

K = zeros(4,12); %Composition Matrix Initiation

% COD row
K(1,:) = [-1 1 1 0 -1.71 -4.57 0 1 1 1 1 1];

% Nitrogen row
K(2,:) = [0 i_N_S_I i_N_S_S 1 0 1 0 i_N_X_I i_N_X_S i_N_BM 0 i_N_BM];

% Charge row
K(3,:) = [0 0 0 1/14 0 -1/14 -1 0 0 0 0 0];

% Suspended solids
K(4,:) = [0 0 0 0 0 0 0 i_SS_X_I i_SS_X_S i_SS_BM 0 i_SS_BM];

%Stoichiometric Matrix Definition

S = zeros(12,13); %Stoichiometry Matrix Initiation
%Hydrolysis (Known)
S(1,2) = f_S_I;
S(1,9) = -1;
S(1,13) = -i_SS_X_S;

%%Known Co-Efficients
%Aerobic Storage of COD (Known)
S(2,3) = -1;
S(2,11) = Y_STO_O2;

%Anoxic Storage of COD (Known)
S(3,3) = -1;
S(3,11) = Y_STO_NOX;

%Aerobic Growth (Known)
S(4,10) = 1;
S(4,11) = -1/Y_H_O2;

%Anoxic Growth (denitrification; Known)
S(5,10) =1;
S(5,11) = -1/Y_H_NOX;

%Aerobic Endogenous Respiration (Known)
S(6,8) = f_X_I;
S(6,10) = -1;

%Anoxic Endogenous Respiration (Known)
S(7,8) = f_X_I;
S(7,10) = -1;

%Aerobic Respiration of X_STO (Known)
S(8,11) = -1;

%Anoxic Respiration of X_STO (Known)
S(9,11) = -1;

%Autotropic Nitrification (Known)
S(10,6) = 1/Y_A;
S(10,12) = 1;

%Aerobic Endogenous Respiration
S(11,8) = f_X_I;
S(11,12) = -1;

%Anoxic Endogenous Respiration
S(12,8) = f_X_I;
S(12,12) = -1;

%%Unknown Co-Efficients
S(1,3) =x1;
S(1,4)=y1;
S(1,7)=z1;

S(2,1)=x2;
S(2,4)=y2;
S(2,7)=z2;

S(3,4)=y3;
S(3,5)=-x3;
S(3,6)=x3;
S(3,7)=z3;

S(4,1)=x4;
S(4,4)=y4;
S(4,7)=z4;

S(5,4)=y4;
S(5,5)=-x5;
S(5,6)=x5;
S(5,7)=z7;

S(6,1) = x6;
S(6,4) = y6;
S(6,7) = z6;

S(7,4) = y7;
S(7,5) = -x7;
S(7,6) = x7;
S(7,7) = z7;

S(8,1) = x8;

S(9,5) = -x9;
S(9,6) = x9;
S(9,7) = z9;

S(10,1) = x10;
S(10,4) = y10;
S(10,7) = z10;

S(11,1) = x11; 
S(11,4) = y11;
S(11,7) = z11;

S(12,4) = y12;
S(12,5) = -x12;
S(12,6) = x12;
S(12,7) = z12;

S(2,13) = t2; 
S(3,13) = t3; 
S(4,13) = t4; 
S(5,13) = t5; 
S(6,13) = t6; 
S(7,13) = t7; 
S(8,13) = t8; 
S(9,13) = t9; 
S(10,13) = t10; 
S(11,13) = t11; 
S(12,13) = t12; 
%%Solving.m

%Matrix multiplication m x n * n x p = m * p

X0 = [
S_O2;
S_I;
S_S;
S_NH4;
S_N2;
S_NOX;
S_ALK;
X_I;
X_S;
X_H;
X_STO;
X_A;
X_SS;
];
%X = X0;

tspan = linspace(0, 500, 10000);% choose time (e.g., days)

[t, X] = ode15s(@(t,X) asm_model(t, X, S, p,X_in), tspan, X0);

%plot (t,X)
totalCOD = X(:,3) + X(:,9) + X(:,10) + X(:,11) + X(:,8);
plot(t, totalCOD)
xlabel('Time')
ylabel('Total COD')

totalN = X(:,4) + X(:,6) + X(:,5) + i_N_S_I*X(:,2) + i_N_S_S*X(:,3) + i_N_X_I*X(:,8) + i_N_X_S*X(:,9) + i_N_BM*X(:,10) + i_N_BM*X(:,12);
plot(t, totalN)
xlabel('Time')
ylabel('Total N')

figure

plot(t, X(:,1), 'LineWidth', 1.5); hold on % S_O2
plot(t, X(:,3), 'LineWidth', 1.5);         % S_S
plot(t, X(:,4), 'LineWidth', 1.5);         % S_NH4
plot(t, X(:,6), 'LineWidth', 1.5);         % S_NOX
plot(t, X(:,10), 'LineWidth', 1.5);        % X_H
plot(t, X(:,11), 'LineWidth', 1.5);        % X_STO
plot(t, X(:,12), 'LineWidth', 1.5);        % X_A

xlabel('Time (days)')
ylabel('Concentration (g/m^3)')
title('ASM3 Key State Variables')

legend({'S_{O2}','S_S','S_{NH4}','S_{NOX}','X_H','X_{STO}','X_A'},'Location','best')

grid on
