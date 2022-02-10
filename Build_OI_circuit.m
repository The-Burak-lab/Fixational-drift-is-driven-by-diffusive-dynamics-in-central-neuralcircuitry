function [xi, r0, eta] = Build_OI_circuit(N)
%BUILD_OI_CIRCUIT Summary of this function goes here
%   Detailed explanation goes here
str = ['NetParm_Fuchs_N_', num2str(N), '.mat'];
Folder = cd;
Folder = fullfile(Folder, '..');
matFileNames = dir(fullfile(Folder,'*.mat'));
for i = 1 : length(matFileNames)
    if contains(matFileNames(i).name, str)
        load(str, 'xi', 'r0', 'eta')
    elseif i==length(matFileNames)
        if N < 10000
            % fit the entire circuit
            disp('--------------------------------------')
            disp('Sit back while we fit the circuit.....')
            disp('--------------------------------------')
            Fit_OI_circuit(N)
        elseif N > 10000
            % use the 5,000 neurons fitted model (the file "NetParm_Fuchs_N_10000.mat") to upscale
            % by considering duplicates of this network
            [xi, r0, eta] = Duplicate_OI_circuit(N);
        end
        % save resulting circuit to file
        str = ['NetParm_Fuchs_N_', num2str(N), '.mat'];
        save(fullfile(Folder,str),'xi','r0', 'eta');        
    end
end
end

