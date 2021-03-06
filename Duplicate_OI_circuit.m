function [xi, r0, eta] = Duplicate_OI_circuit(N)
% This function generates a connectivity matrix for the Oculomotor
% Integrator of size N. It does so by exploiting previously fitted 
% smaller networks
% Inputs: N, size of required OI network
% Outputs: xi, r0, eta - all are vectors of size N, which establish the 
%          connectivity matrix of the OI
%----------------------------------------------------------------------
if mod(N,10000) <= mod(N,5000)
    str = ['NetParm_Fuchs_N_', num2str(10000), '.mat'];
    % the number of duplicates
    p = floor(N/10000);
else
    str = ['NetParm_Fuchs_N_', num2str(5000), '.mat'];
    % the number of duplicates
    p = floor(N/5000);
end
load(str, 'xi', 'r0', 'eta')
% duplicate previous fitted model, keeping total input to each
% cell constant
xi = repmat(xi,p,1);
r0 = repmat(r0,p,1);
eta = repmat(eta,1,p)/p;
end

