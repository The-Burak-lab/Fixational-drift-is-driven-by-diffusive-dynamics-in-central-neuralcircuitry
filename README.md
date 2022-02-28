# Fixational-drift-is-driven-by-diffusive-dynamics-in-central-neural-circuitry
This repository provides the code of the computational model presented in the paper "Fixational drift is driven by diffusive dynamics". When using this code, please cite the paper. Currently please use the citation below, but please check here for updates on the appropriate citatation:
bioRxiv 2021.02.10.430643; doi: https://doi.org/10.1101/2021.02.10.430643

The repository includes several ".mat" files as follows:
- monkeys_MSD: this file includes the raw data of the MSD calcaulted from the measurements for both monkeys.
- NetParm_Fuchs_N_XXX: this file includes the tunining curves of XXX neurons in the monkeys oculomotor integrator. The tuning curves are sampled from a distribution measured in a paper by Fuchs, 1992. In addition it includes the readout vector, which was fitted such that a continum of fixed points is maintained by the dynamic of the network. The fitting process is done according to the paper: Functional dissection of circuitry in a neural integrator, 2007 by Aksay et-al. 
- OMNparameters: this file includes the parameters of the OMNs based on information found in the literature (see paper for details). The parameters are the eye position threshold, position, velocity and accelration sensetivies. 

In addition the repository includes ".m" files as follows:
- "Run_model.m": this is the main file  which executes the dynamics of the network and saves the results to ".mat" files.
- "Full_model_simulation": this file contains the dynamical equations of our model and actually caries all the math.
- "draw_from_linear_regression": auxiliary function which samples parameters randomly according to Eqs.29,30,32 in the paper.
- "msdFFT": auxiliary function which calculates the meas sqaured displacement exploiting the Wiener-Khinchin theorem and the FFT algorithm.
- "Build_OI_circuit.m": this function constructs an oculomotor integrator connectivity matrix of desired size (resolution of 5,000 neurons).  
