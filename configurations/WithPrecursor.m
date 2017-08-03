% SOWFA source directories and meshing options
sourcepath      = 'WFSim\Data_SOWFA\WithPrecursor\2turb_50x25_lin';  % Specify location of SOWFA data (excluding backslash at the end)
datanroffset    = 20000;                                             % Numbering offset (first filenumber is datanroffset+1)
Wp.name         = 'noprecursor_2turb_50x25_lin';                     % Name of meshing (from "meshing.m")
sensors_path    = ['Setup_sensors\sensor_layouts\' ...               % Specify file with sensor (measurement) locations
                   'sensors_yaw_2turb_50x25_lin_2row_downwind.mat']; 

% Model settings
options.startUniform  = 1;    % Start from a uniform flow field (1) or from a fully developed waked flow field (0).
conv_eps              = 1e-6; % Convergence parameter
max_it_dyn            = 1;    % Convergence parameter
max_it                = 1;    % Convergence parameter

% Environment/SOWFA settings
strucObs.filtertype      = 'sim'; % Observer types are outlined below in "Filter settings"
strucObs.obsv_delay      = 000;    % Number of time steps after which the observer is enabled (between 0 and NN-1)
strucObs.loadrandomseed  = 1;      % Load a predefined random seed (for one-to-one comparisons between simulation cases)
strucObs.noise_obs       = 0.1;    % Disturbance amplitude (m/s) in output data by randn*noiseampl ('0' for no noise)
strucObs.noise_init      = 0.0;    % Disturbance amplitude (m/s) in initial flow field by randn*noiseinit ('0' recommended)
strucObs.noise_input     = 0.0;    % Noise on input vector beta, enforced by the command "randn*beta"

switch lower(strucObs.filtertype)
        case {'ukf'}
        % Filter settings
        strucObs.stateEst = false;  % Do state estimation: true/false
        strucObs.R_k   = 0.10;      % Measurement   covariance matrix   
        strucObs.Q_k.u = 0.10;      % Process noise covariance matrix 
        strucObs.Q_k.v = 0.01;      % Process noise covariance matrix 
        strucObs.P_0.u = 0.10;      % Initial state covariance matrix 
        strucObs.P_0.v = 0.10;      % Initial state covariance matrix 
        
        strucObs.alpha = 1e0;
        strucObs.beta  = 2; % 2 is optimal for Gaussian distributions
        strucObs.kappa = 0;% "0" or "3-L"
        
        % Pressure terms and covariances
        options.exportPressures = 0;   % Model/predict/filter pressure terms
        strucObs.Q_k.p          = 1.0; % Process noise covariance matrix 
        strucObs.P_0.p          = 0.5; % Initial state covariance matrix 
        options.Linearversion   = 0;   % Calculate linearized system matrices    
        
        % Online model parameter adaption/estimation/tuning
        strucObs.tune.vars = {'turbine.forcescale','site.lmu'}; % If empty {} then no estimation
        strucObs.tune.Q_k  = [3e-6,3e-4]; % Standard dev. for process noise 'u' in m/s
        strucObs.tune.P_0  = [5e-5,5e-2]; % Width of uniform dist. around opt. estimate for initial ensemble
        strucObs.tune.lb   = [0.00,0.00]; % Lower bound
        strucObs.tune.ub   = [6.00,6.00]; % Upper bound
        
    case {'exkf'}
        strucObs.R_k     = 1.0;    % Measurement   covariance matrix diagonal entries
        strucObs.Q_k     = 1.0;    % Process noise covariance matrix diagonal entries 
        strucObs.P_0     = 0.5;    % Initial state covariance matrix diagonal entries 
        
        strucObs.diagP   = true;   % Neglect all off-diagonal elements in P
        strucObs.sparseF = true;   % Sparsify F matrix to reduce number of operations
        strucObs.Fthresh = 0.01;   % Neglect values smaller than [*] in F (if above is set to true)
        
        options.exportPressures   = 0;  % Model/predict/filter pressure terms
        options.Linearversion = 1; % MUST BE 'TRUE'. Calculate linearized system matrices
        
    case {'enkf'}
        strucObs.nrens   =   50;         % Ensemble size
        
        % Default state parameters
        strucObs.R_e     =   0.10;       % Standard dev. for measurement noise ensemble
        strucObs.Q_e.u   =   0.15;       % Standard dev. for process noise 'u' in m/s
        strucObs.Q_e.v   =   0.04;       % Standard dev. for process noise 'v' in m/s
        strucObs.W_0.u   =   4.00;       % Width (in m/s) of uniform dist. around opt. estimate for initial ensemble
        strucObs.W_0.v   =   0.50;       % Width (in m/s) of uniform dist. around opt. estimate for initial ensemble
        
        % Online model parameter adaption/estimation/tuning
        strucObs.tune.vars = {};%{'turbine.forcescale','site.Rho'};
        strucObs.tune.Q_e  = [];%[0.01,0.01]; % Standard dev. for process noise 'u' in m/s
        strucObs.tune.W_0  = [];%[0.15,0.10]; % Width of uniform dist. around opt. estimate for initial ensemble
        strucObs.tune.lb   = [];%[0.00,1.00]; % Lower bound
        strucObs.tune.ub   = [];%[2.00,1.40]; % Upper bound
        
        % Pressure terms
        options.exportPressures =   false; % Include pressure terms in ensemble members (default: false)
        strucObs.W_0.p          =   0.00;  % Width (in m/s) of uniform dist. around opt. estimate for initial ensemble.
        strucObs.Q_e.p          =   0.00;  % Standard dev. for process noise 'p' in m/s
       
        % Power filtering and estimation
        strucObs.measPw       = false;    % Use power measurements from turbines in estimates
        strucObs.R_ePW        = 1e-3;     % Measurement noise for turbine power measurements
        
        % EnKF localization and inflation
        strucObs.r_infl         =   1.02;       % Covariance inflation factor (typically 1.00-1.20, no inflation: 1)
        strucObs.f_locl         =   'gaspari';  % Localization method: 'off', 'gaspari' (Gaspari-Cohn 1999) or 'heaviside' (Heaviside step function: 0s or 1s)
        strucObs.l_locl         =   131;        % Gaspari-Cohn: typically sqrt(10/3)*L with L the cut-off length. Heaviside: cut-off length (m).
        
        % Other settings (disable unnecessary calculations in model)
        options.Linearversion   = 0;            % Do not calculate linearized system
        
    case {'sim'}
        options.exportPressures = 1; % Do not change for sim case.
        options.Linearversion   = 0; % Do not calculate linearized system matrices
        
    otherwise
        error('not a valid filter/simulation specified.');
end;