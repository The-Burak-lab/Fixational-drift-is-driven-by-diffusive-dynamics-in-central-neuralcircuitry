function Run_model(N, nMN, redOI, A_feed, Time, NoOfTraj, verbose)
% This function sets the model parameters, and runs the simulation
% Inputs:
%       N: # of OI neurons
%       nMN: # of OMNs
%       redOI: # of spk thining in the integrator, it controls the coefficient of variation of neurons in the inetgrator
%       A_feed: feedback amplitude
%       Time: total simulation time (s)
%       verbose: 'spike' or 'rate', simulations of full model or rate based
%       model
% Output:
%       A .mat file with simulation results    
%--------------------------------------------------------------------------

parameters.SE = 0; % desired fixation location

tau_s = 0.02; % synaptic char. time [sec]

tau_feed = 0.07; % Visual feedback delay [sec]
MOD = 100; % save every # timestep
%% Create folder for results, and move into that folder
c = clock;
folderName = sprintf('Simulation_results_month_%d_day_%d_time_%dh_%dm',c(2),c(3),c(4),c(5));
mkdir(folderName)
addpath(genpath(pwd))
cd(folderName)
% save parameters
parameters.N = N;
parameters.nMN = nMN;
parameters.A_feed = A_feed;
parameters.tau_feed = tau_feed;
parameters.tau_s = tau_s;
parameters.dt = 1e-5;
parameters.Time = Time;
parameters.folderName = folderName;
parameters.redOI = redOI;
parameters.MOD = MOD;
save('parameters.mat','parameters')

%% Run the simulation
% Here several eye trajectories are genreated and saved to disk
tic
for ii = 1:NoOfTraj
    disp(['simulating traj ',num2str(ii),'/',num2str(NoOfTraj)] )
    parameters.Seed = ii;
    if strcmp(verbose, 'spike')
        Full_model_simulation(parameters);
    elseif strcmp(verbose, 'rate')
        Model_wo_spiking_noise(parameters)
    end
end
toc
%% Calculate MSD from saved eye traj.
CalculateMSD();
end
