% Source files
scriptOptions.outputFilename = '4turb_adm_turb';
scriptOptions.plotFrequency  = 100;         % Plot mapping every * instances (will always plot k == 1, set to high value for no plots after k == 1)
scriptOptions.sourcePath     = 'V:/3me/dcsc/DataDriven\Data\PALM/4turb_adm_matlab/St_0.25___A_1.5';

% Turbine properties directly from PALM or SOWFA. The reference frame is 
%   x (vertical, upwards pos.) - y (horizontal, rightwards pos.).
rawTurbData           = struct('Crx',[210 810 1410 2010],...
                                'Cry',[160 160 160 160]);
rawTurbData.Drotor    = [120, 120, 120, 120]; % Rotor diameter in (m)
rawTurbData.hubHeight = 90.0;           % Hub height in (m)

% Filtering
filterSettings.turbData.MM = true; % Apply moving average to turbine data
filterSettings.turbData.tL = 1;    % Window width to the left (seconds)
filterSettings.turbData.tR = 1;    % Window width to the right (seconds)

%filterSettings.Ur.nPts = 50;    % Number of rotor points (only if CT not available)
%filterSettings.Ur.MM   = true;  % Moving-average for rotor velocity (Only when CT not given)
%filterSettings.Ur.tL   = 5;     % Moving-average for rotor velocity (Only when CT not given)
%filterSettings.Ur.tR   = 5;     % Moving-average for rotor velocity (Only when CT not given)

filterSettings.CTp.MM   = true;  % Additional moving-mean average for Ct_prime
filterSettings.CTp.tL   = 3;     % Additional moving-mean average for Ct_prime
filterSettings.CTp.tR   = 3;     % Additional moving-mean average for Ct_prime

% Desired output settings
meshSetup.dt          = 1.0 ; % Timestep in seconds
meshSetup.rho         = 1.20; % Air density (kg m^-3)
meshSetup.distance_S  = 250 ; % distance (m) upwind   first  turbine to export
meshSetup.distance_N  = 250;  % distance (m) downwind  last  turbine to export
meshSetup.distance_W  = 150 ; % distance (m) west most left  turbine (from hub) to export
meshSetup.distance_E  = 150 ; % distance (m) east most right turbine (from hub) to export
meshSetup.Nx          = 100;   % Number of grid points in x-direction (-)
meshSetup.Ny          = 50;   % Number of grid points in y-direction (-)