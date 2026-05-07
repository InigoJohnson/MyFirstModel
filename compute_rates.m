function r = compute_rates(X, p)
% Computes ASM3 process rates (r1–r12)
% INPUT:
%   X : state vector (13×1)
%   p : parameter struct
% -------- State variables --------
S_O2  = X(1);   % g O2/m3
S_I   = X(2);
S_S   = X(3);   % g COD/m3
S_NH4 = X(4);   % g N/m3
S_N2  = X(5);
S_NOX = X(6);   % g N/m3
S_ALK = X(7);

X_I   = X(8);
X_S   = X(9);
X_H   = X(10);  % g COD/m3
X_STO = X(11);  % g COD/m3
X_A   = X(12);  % g COD/m3
X_SS  = X(13);

% -------- Stability fix --------
X_H = max(X_H, 1e-6);

% -------- Parameters --------
k_H     = p.k_H;
K_X     = p.K_X;

k_STO   = p.k_STO;
eta_NOX = p.eta_NOX;
K_O2    = p.K_O2;
K_NOX   = p.K_NOX;
K_S     = p.K_S;
K_STO   = p.K_STO;
mu_H    = p.mu_H;
K_NH4   = p.K_NH4;
K_ALK   = p.K_ALK;

b_H_O2   = p.b_H_O2;
b_H_NOX  = p.b_H_NOX;
b_STO_O2 = p.b_STO_O2;
b_STO_NOX= p.b_STO_NOX;

mu_A    = p.mu_A;
K_A_NH4 = p.K_A_NH4;
K_A_O2  = p.K_A_O2;
K_A_ALK = p.K_A_ALK;
b_A_O2  = p.b_A_O2;
b_A_NOX = p.b_A_NOX;
K_A_NOX = p.K_A_NOX;

% -------- Process Rates --------
% Hydrolysis
r1 = k_H * ((X_S/X_H)/(K_X + (X_S/X_H)))*X_H; 

% heterotropic organisms, aerobic and denitrifying activity
%Aerobic Storage of S_S
r2 = k_STO * (S_O2/(K_O2 + S_O2))* (S_S/(K_S + S_S))* X_H; 

%Anoxic Storage of S_S
r3 = k_STO * eta_NOX * (K_O2/(K_O2 + S_O2)) * (S_NOX/(K_NOX + S_NOX)) * (S_S/(K_S + S_S)) * X_H; 

%Aerobic Growth
r4 = mu_H * (S_O2/(K_O2 + S_O2)) * (S_NH4/(K_NH4 + S_NH4)) * (S_ALK/(K_ALK + S_ALK)) * ((X_STO/X_H)/(K_STO + (X_STO/X_H))) * X_H;

%Anoxic Growth (Denitrification)
r5 = mu_H * eta_NOX * (K_O2/(K_O2 + S_O2)) * (S_NOX/(K_NOX + S_NOX)) * (S_NH4/(K_NH4 + S_NH4)) * (S_ALK/(K_ALK + S_ALK)) * ((X_STO/X_H)/(K_STO + (X_STO/X_H))) * X_H; 

%Aerobic Endogenous Respiration
r6 = b_H_O2 * (S_O2/(K_O2 + S_O2)) * X_H;

%Anoxic Endogenous Respiration
r7 = b_H_NOX * (K_O2/(K_O2 + S_O2)) * (S_NOX/(K_NOX + S_NOX)) * X_H;

%Aerobic Respiration of X_STO
r8 = b_STO_O2 * (S_O2/(K_O2 + S_O2)) * X_STO;

%Anoxic Respiration
r9 = b_STO_NOX * (K_O2/(K_O2 + S_O2)) * (S_NOX/(K_NOX + S_NOX)) * X_STO;

% Autotropic Organisms - Nitrifying activity

%Aerobic Growth of X_A , Nitrification
r10 = mu_A * (S_O2/(K_A_O2 + S_O2)) * (S_NH4/(K_A_NH4 + S_NH4)) * (S_ALK/(K_A_ALK + S_ALK)) * X_A;

%Aerobic Endogenous respiration of X_A
r11 = b_A_O2 * (S_O2/(K_A_O2 + S_O2)) * X_A;

%Anoxic Endogenous Respiration
r12 = b_A_NOX * (K_A_O2/(K_A_O2 + S_O2)) * (S_NOX/(K_A_NOX + S_NOX)) *X_A;

% -------- Output --------
r = [r1; r2; r3; r4; r5; r6; r7; r8; r9; r10; r11; r12];

end
