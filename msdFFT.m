function MSD = msdFFT(x)
% This function calculates the MSD over "N" iid eye trajectories
% of length "T", it used FFT for efficient implementation
% Inputs:
%           x: N by T array of "N" eye traj. of length "T" each
% Output:
%           MSD: the MSD averaqed over all different eye traj.

if iscell(x)
    error('no support')
else
    [N, s] = size(x);
    D = mean(x.*x, 2);
    D = [D; 0];
    S2 = zeros(2*N-1, 1);
    for i = 1:s
        S2 = S2 + xcorr(x(:, i), 'unbiased');
    end
    S2 = S2 / s;
    S2 = S2(N:end);
    Q = 2 * sum(D);
    S1 = zeros(N, 1);
    for m = 0:N - 1
        if m > 0
            Q = Q - D(m) - D(N-m+1);
            S1(m+1) = Q / (N - m);
        else
            S1(m+1) = Q / N;
        end
    end
    MSD = S1 - 2 * S2;
end
end
