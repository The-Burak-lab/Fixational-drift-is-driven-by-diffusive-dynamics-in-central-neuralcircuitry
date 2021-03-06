function Full_model_simulation(parameters) 
% This function simulates the dynamics of the entire system: oculomotor integrator (O.I) -> OMNs -> final eye position
% The model of the O.I is an adaptation of the model suggested by E. Aksay, M. Goldman. D. Tank, 2007
% Inputs:   parameters, a struct object, which contains the different parameters for the model.
% Output:   The function saves two "*.mat" files, one with the parameters used in simualtion and one 
%           with both the final eye position and its representaion in the O.I. In addition it saves 
%           the information on OMNs spike times.
%------------------------------------------------------------------------------------------------------
global xi r0 eta v
%% Unpack model parametes
Seed = parameters.Seed;
Time = parameters.Time;
dt = parameters.dt;
N = parameters.N;
Nm = parameters.nMN;
tau_feed = parameters.tau_feed;
tau_s = parameters.tau_s;
redOI = parameters.redOI;
SE = parameters.SE;
MOD = parameters.MOD;
A_feed = parameters.A_feed;
Sig_DownStream = 0;
r_0 = 60;
%% Parameters
rng(Seed);
simtime = round(Time/dt);
n_step_feed = round(tau_feed/dt);
tau_MN = 0.01; % MN synapse time const.

dt_tau_s = 1 - dt / tau_s;
dt_tau_MN = 1 - dt / tau_MN;

% Set the tuning curves and their fit
% if the required OI size is already fitted - load it
% else - fit the desired circuit
[xi, r0, eta] = Build_OI_circuit(N);

% update the value of N according to fitted circuit
N = length(xi);

% set OMN tuning curves
% The mat file contains 1000 OMNs. Adjust the required number of OMNs by
% either cutting of duplicating tuning curves from the file
load('OMNparameters.mat', 'alpha')

Na = length(alpha);
if Nm < Na
    ind = round(linspace(1, Na, Nm));
    alpha = alpha(ind, :);
    Na = Nm;
else
    MOD_omn = mod(Nm, Na);
    NoOfAlphaDuplicates = (Nm - MOD_omn) / Na;
    alpha = repmat(alpha, NoOfAlphaDuplicates, 1);
    rndInd = randi(Na, MOD_omn, 1);
    alpha = [alpha; alpha(rndInd, :)];
end
Na = Nm;

%% Set the OMNs Coefficient of Variation (CV)
% CV  depends on the ISI - Gomez, 1986
Expected_OMN_rate = alpha(:, 1) * SE + alpha(:, 4);
non_activ_MN_ind = Expected_OMN_rate < 0;
tempISI = 1000 ./ Expected_OMN_rate; % ISI in ms

% Set OMNs ISI < 1s,
tempISI(non_activ_MN_ind) = 1000;
tempISI(tempISI > 1000) = 1000;

% Set the OMNs CV from the realtion reported in Gomez, 1986
tempCV = draw_from_linear_regression(.18, 7.3, .79, tempISI) / 100;
% Box constraint on CV
tempCV(tempCV > 1) = 1;
tempCV(tempCV < 0.04) = .04;

% Set the requireed # of OMNs spike thining to achieve the desired CV
redMN = round(1./(tempCV.^2)); % each MN has it own CV. therefore its own spike thinning
redMN(redMN > 400) = 400;

%% Simulation - doing the math....

%I.C of Oculomotor integrator
rR(:, 1) = SE * xi + r0;
rR(rR(:, 1) < 0) = 0; % rates of right population
rL(:, 1) = -SE * xi + r0;
rL(rL(:, 1) < 0) = 0; % rates of left population
SR = sinf(rR);
SL = sinf(rL);

% I.C of OMNs
Epfix = eta * (SR - SL);
MN_eye = ones(Na, 1) * Epfix; % eye position determined from OMNs
MN_rate = alpha(:, 1) * Epfix + alpha(:, 4);
MN_synapse = MN_rate;

% Initialize spike thining counter - both OI and OMN
spikeCountMN = round((redMN-1).*rand(Na, 1)); % MN spk counter, counts the incereased rate spikes for spike thinning
MN_counter = zeros(Na, 1); % counts the actual spikes
spikeCountR = round((redOI-1)*rand(N, 1));
spikeCountL = round((redOI-1)*rand(N, 1));

% Initialize array for final eye position
X_0 = ones(simtime+1, 1) * Epfix; % Real eye location
v = zeros(Na, 1);
count = 1;

% Initialize feedback initally at 0
Feed = 0;

% Initialize spike times array
spikeTimes = cell(1, Nm);

% Run the network dynamics

for i = 1:simtime
    % Spiking model
    EP = eta * (SR - SL); % eye location (represented in the OI)
    EP_spk = EP;

    % The OMN channel
    MN_spks = Eye_position_from_MN(EP); % Draw OMNs spikes from OI command
    MN_counter = MN_counter + MN_spks;

    % Save OMNs spikes times
    if ~isempty(MN_spks)
        tempind = find(MN_spks);
        for spkind = 1:length(tempind)
            spikeTimes{tempind(spkind)}(MN_counter(tempind(spkind))) = i * dt;
        end
    end

    % Transform OMNs spikes to actual eye position - double exp filter
    MN_synapse = MN_synapse * dt_tau_MN + MN_spks / tau_MN;
    v_old = v;
    RATE = alpha(:, 4) + alpha(:, 1) * X_0(i) + alpha(:, 2) .* v_old;
    v = v_old + dt * (MN_synapse - RATE + Sig_DownStream * randn(Na, 1) / sqrt(dt)) ./ alpha(:, 3); % MN_spks <-> MN synapse
    MN_eye = MN_eye + dt * v;
    X_0(i+1) = mean(MN_eye); % Average across OMN signal to get final eye position

    %sensory feedback:
    if i > n_step_feed
        Feed = A_feed * (X_0(i - n_step_feed) - EP);
    end

    % OI dynamics
    rR = (xi * EP_spk + r0 + xi * Feed); % rates are instentenous
    rL = (-xi * EP_spk + r0 - xi * Feed); % rates are instentenous
    rR(rR < 0) = 0; % rates are non-negative
    rL(rL < 0) = 0; % rates are non-negative


    % OI spike thinning
    spikesR = zeros(N, 1);
    spikesL = zeros(N, 1);
    IR = find(rand(N, 1) < redOI*dt*rR);
    if ~isempty(IR)
        spikeCountR(IR) = spikeCountR(IR) + 1;
        I2 = find(spikeCountR == redOI);
        spikesR(I2) = 1;
        spikeCountR(I2) = 0;
    end
    IL = find(rand(N, 1) < redOI*dt*rL);
    if ~isempty(IL)
        spikeCountL(IL) = spikeCountL(IL) + 1;
        I2 = find(spikeCountL == redOI);
        spikesL(I2) = 1;
        spikeCountL(I2) = 0;
    end

    % Populations activities
    SR = (dt_tau_s) * SR + (spikesR ./ (r_0 + rR)) / tau_s;
    SL = (dt_tau_s) * SL + (spikesL ./ (r_0 + rL)) / tau_s;

    % Save trajectories
    if mod(i+MOD-1, MOD) == 0
        EyePos(count) = EP;
        X(count) = X_0(i);
        MNeye(:, count) = MN_eye; %estimated eye position based on single OMN
        count = count + 1;
    end

end

%% Saving:
str = ['N=', num2str(N), '_ReduceSpike_', num2str(redOI), '_Adaptation_eps_', num2str(eps), '_EyePos_', num2str(SE), 'A_feed=', num2str(A_feed), 'tau_feed=', num2str(tau_feed), '_traj_', num2str(Seed), '.mat'];
SaveStruct.Fixation_position = SE;
SaveStruct.reduceOIspikes = redOI;
SaveStruct.N_OI = N;
SaveStruct.FeedbackAmp = A_feed;
SaveStruct.FeedbackDelay = tau_feed;
SaveStruct.OMNspikeTimes = spikeTimes;
SaveStruct.OI_eyeTrajectory = EyePos;
SaveStruct.Final_eyeTrajectory = X;
SaveStruct.OMNprediction = MNeye;
SaveStruct.dt = dt;
SaveStruct.Save_every_Step = MOD;
SaveStruct.Simulation_totalTime = Time;

save(str,'-struct','SaveStruct')

%% Auxilary functions

    function sinf1 = sinf(r)
       % One of the non-linearities in OI, suggested in E Aksay et-al, 2007
        sinf1 = r ./ (r_0 + r);
    end

    function MN_spikes = Eye_position_from_MN(EP)
        MN_spikes = zeros(Na, 1);
        MN_rate = alpha(:, 1) * EP + alpha(:, 4);
        MN_rate(MN_rate < 0) = 0; %  rates are non-negative
        I_MN_spk = find(MN_rate.*redMN*dt > rand(Na, 1)); % increased OMNs rate
        if ~isempty(I_MN_spk)
            spikeCountMN(I_MN_spk) = spikeCountMN(I_MN_spk) + 1;
            reduceMN_spk = find(spikeCountMN == redMN);
            MN_spikes(reduceMN_spk) = 1;
            spikeCountMN(reduceMN_spk) = 0;
        end
    end
end
