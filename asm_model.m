function dXdt = asm_model(t, X, S, p,X_in)

r = compute_rates(X, p);

dXdt = S' * r;
% --- Aeration term ---
kLa   = p.kLa;      % 1/day
S_sat = p.S_sat;    % g/m^3

dXdt(1) = dXdt(1) + kLa * (S_sat - X(1));

% % --- CSTR flow term ---
% dXdt = dXdt + (p.D * (X_in - X));

% --- CSTR flow (ONLY solubles) ---
for i = 1:7
    dXdt(i) = dXdt(i) + p.D * (X_in(i) - X(i));
end

% --- SRT control (ONLY particulates) ---
for i = 8:13
    dXdt(i) = dXdt(i)  - (1/p.SRT) * X(i);
    % if i == 10
    %     i
    %     dXdt(i)
    %     (1/p.SRT) * X(i)
    % elseif i == 12
    %     i
    %     dXdt(i)
    %     (1/p.SRT) * X(i)
    % end

end

end