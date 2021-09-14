function MSD = CalculateMSD(path)
% This function calculated the MSD of the computational model
% Input:
%           path: str, path to directory in which eye trajectories are save
%                 as different .mat files
%           plot: in addition this function plots the MSD against the 
%                 MSD as mesaured from data (loads it from .mat file)
% Output:
%           MSD: MSD of final eye position
%----------------------------------------------
% load the MSD measured in data
load('monkeys_MSD.mat')
% if using Linux exchange \ -> /
fname = dir([path,'\*.mat']);
X = []; % initialize arrat of actual eyetraj..
for i = 1:length(fname) - 1
    load(fname(i).name)
    X(:,i) = Final_eyeTrajectory;
end
MSD = msdFFT(X);

figure
timeLags = (0:length(X) - 1) * dt * Save_every_Step;
% plot the monkey data
loglog(10.^x1(20:end - 600), 10.^y1(20:end - 600), '.', 'markersize', 16)
hold on
loglog(10.^x2(25:end - 600), 10.^y2(25:end - 600), '.', 'markersize', 16)

% plot the computational MSD
loglog(timeLags, MSD, 'k-', 'linewidth', 3) % ground truth, MSD wo\measure noisep


legend('Monkey I', 'Monkey P', 'Model', 'location', 'best')
xlabel('\Deltat (s)')
ylabel('MSD (deg^{2})')
axis([0.01, 1, 1e-5, 1e-1])
end

