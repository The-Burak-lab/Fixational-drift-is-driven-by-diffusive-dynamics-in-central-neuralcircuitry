# Fixational-drift-is-driven-by-diffusive-dynamics-in-central-neuralcircuitry
This repository provides the code of the computational model presented in the paper "Fixational drift is driven by diffusive dynamics"

It includes several ".mat" files as follows:
- monkeys_MSD: this file includes the raw data of the MSD calcaulted from the measurements for both monkeys.
- NetParm_Fuchs_N_10000: this file includes the tunining curves of 10,000 neurons in the monkeys oculomotor integrator. The tuning curves are sampled from a distribution measured in a paper by Fuchs, 1992. In addition it includes the read out vector, which was fitted such that a continum of fixed points is maintained by the dynamic of the network. 
- OMNparameters: this file includes the parameters of the OMNs based on information found in the literature (see paper for details). The parameters are the eye position threshold, position, velocity and accelration sensetivies. 

In addition the repository includes ".m" files, the main file is "Run_model" which executes the dynamics of the network and saves the results to ".mat" files.

