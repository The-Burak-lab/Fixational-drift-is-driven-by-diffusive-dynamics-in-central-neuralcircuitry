function Fit_OI_circuit(N)
% Fits the oculomotor integrator of the primate based on tuning curves measures by
% Fuchs, 1992
% Input:    N, # of neurons in the integrator
%
% Output:  .mat file with OI parameters
%------------------------------------------

% init. array of possible eye positions
E = linspace(-50,50,round(2*N))'; % keep the binning of eyepostion in finer resolution then # of neurons

% The range of OI neurons thresholds
T_range = [-60,5]; % in degrees
% sample randomly slopes and threhsolds
[xi,T] = draw_from_linear_regression(0.032,4.04,0.61,T_range,N);
% in the data it seems to not go below this value
% in addition it coudn't be negative
xi(xi<1.2) = 1.2 ;
r0 = -(xi.*T); % firing rate at straight gaze 

% firing rate at equilibirum of both L and R populations
reqR = bsxfun(@plus,E*xi',r0');
reqL = bsxfun(@plus,-E*xi',r0');
reqR(reqR<0)=0;reqL(reqL<0)=0;


C = [sinf(reqR)-sinf(reqL)]; 

options = optimset('MaxIter',3000);% use optimoptions instead in new Mat vers
eta =  lsqlin(C,E,[],[],[],[],(1/N/10)*ones(N,1),(100/N)*ones(N,1),[],options)'; 
% figure; plot(E,C(1:length(E),:)*eta'-E),hold on
save(['NetParm_Fuchs_N_',num2str(N),'.mat'],'xi','eta','r0')
function sinf1 = sinf(r)
    sinf1 = r./(60+r);
end
end

