% Build an ArbLoop model of the IMC_Simple.mdl Simulink model loacted in
% the CARM directory of the noise budget svn.  
%
% The model will be built from the Simulink drawing by building all of the
% blocks seperately, and then connecting them together.
function loop = ArbLoop_IMC_Simple()

clear loop

check = 0;

%% Initialize

% Add the ArbLoop directory to the path.
addpath('../')

% Initalize the ArbLoop model
loop = ArbLoop();


%%
%%%------------------------------------------------------------------------
%%% MC2 with Electronics and Controllers
%%%------------------------------------------------------------------------

%% Add the Suspension Model and Electronics
% Load the stored state space model of the suspension
load sus.mat

% Add suspension model to ArbLoop model
loop = addBlockSS( loop, 'MC2', sus.hsts.ss, ...
    {'Gndi', 'M1i', 'M2i', 'M3i'}, {'M1o', 'M2o', 'M3o'});

% Connect Electronics
loop = connectBlock( loop, 'MC2: M1 A2N', [], [], 0.963, ...
    '', 'MC2: M1i');
loop = connectBlock( loop, 'MC2: M2 A2N', [], [], 0.0158, ...
    '', 'MC2: M2i');
loop = connectBlock( loop, 'MC2: M3 A2N', [], [], 0.00281, ...
    '', 'MC2: M3i');
loop = connectBlock( loop, 'MC2: M1 Coil', [], [], 11.9e-3, ...
    '', 'MC2: M1 A2N');
loop = connectBlock( loop, 'MC2: M2 Coil', [], [], 0.32e-3, ...
    '', 'MC2: M2 A2N');
loop = connectBlock( loop, 'MC2: M3 Coil', [], [], 0.32e-3, ...
    '', 'MC2: M3 A2N');
loop = connectBlock( loop, 'MC2: M1 DAC', [], [], 20/(2^18), ...
    '', 'MC2: M1 Coil');
loop = connectBlock( loop, 'MC2: M2 DAC', [], [], 20/(2^18), ...
    '', 'MC2: M2 Coil');
loop = connectBlock( loop, 'MC2: M3 DAC', [], [], 20/(2^18), ...
    '', 'MC2: M3 Coil');

%% Add the Damping Filters
loop = connectBlock( loop, 'MC2: Damp', ...
    0, [15+1i*25.9808 15-1i*25.9808], 2*pi*abs((15+1i*25.9808))^2*(-10), ...
    'MC2: M1o', '');
loop = insertLink( loop, 'MC2: Damp', 'MC2: M1i');

%% Add the Controllers
% Load the stored controller filters.
load IMC_Filters_Mod.mat
mc2m1l = -1/12*mc2m1l;
mc2m3l = 2.25*mc2m3l;

% Add controllers to model and connect to the suspension electronics.
loop = connectBlock( loop, 'MC2: M1 Ctrl', mc2m1l, '', 'MC2: M1 DAC');
loop = connectBlock( loop, 'MC2: M2 Ctrl', mc2m2l, '', 'MC2: M2 DAC');
loop = connectBlock( loop, 'MC2: M3 Ctrl', mc2m3l, '', 'MC2: M3 DAC');

% Connect the Stages
loop = insertLink( loop, 'MC2: M3 Ctrl', 'MC2: M2 Ctrl');
loop = insertLink( loop, 'MC2: M2 Ctrl', 'MC2: M1 Ctrl');

%% Cav Disp is Double the Mirror Disp
loop = connectBlock( loop, 'MC2: Cav Disp', [], [], 2, ...
    'MC2: M3o', '');

%% Add Sinks and Sources
loop = connectSource( loop, 'ISI Disp', 'MC2: Gndi');
loop = connectSink( loop, 'M2 Disp', 'MC2: M2o');

%%
%%%------------------------------------------------------------------------
%%% LSC Controller and ADC
%%%------------------------------------------------------------------------

%% Add Filters and ADC
% Filters
loop = addBlock( loop, 'LSC: Ctrl', imcl);

% ADC
loop = connectBlock( loop, 'LSC: ADC', [], [], 2^16/40, ...
    '', 'LSC: Ctrl');

%% Connect to MC3 Ctrl Input
loop = addLink( loop, 'LSC: Ctrl', 'MC2: M3 Ctrl');

%%
%%%------------------------------------------------------------------------
%%% Common Mode Servo
%%%------------------------------------------------------------------------

% We will start from the variable gain input and work towards the fast path
% output first.  Then we will insert a connection for the slow path output.

%% Varaible Gain Input to Fast Output
loop = addBlock( loop, 'CMS: Gain 1', [], [], 4.3);
loop = connectBlock( loop, 'CMS: Comp', 4e3, 40, 1, ...
    'CMS: Gain 1', '');
loop = connectBlock( loop, 'CMS: Boost 1', 20e3, 1e3, 1, ...
    'CMS: Comp', '');
loop = connectBlock( loop, 'CMS: Fast Pol', [], [], -1, ...
    'CMS: Boost 1', '');
loop = connectBlock( loop, 'CMS: Fast Filt', 70e3, 140e3, 2, ...
    'CMS: Fast Pol', '');

%% Slow Path Output
loop = addBlock( loop, 'CMS: Slow Dif', [], [], 2);
loop = insertLink( loop, 'CMS: Boost 1', 'CMS: Slow Dif');

%% Connect to LSC
loop = addLink( loop, 'CMS: Slow Dif', 'LSC: ADC');

%%
%%%------------------------------------------------------------------------
%%% Cavity/Sensing
%%%------------------------------------------------------------------------

% We will work backwards from the Sensing output to the freqeuncy and 
% length inputs.  Afterwards we will insert the two output paths for the 
% transmitted frequency.

%% Frequency and Length to Error Signal
% Error signal backwards to sum point
loop = addBlock( loop, 'IMC: Demod', [], [], 10);
loop = connectBlock( loop, 'IMC: Transimp', [], [], 460, ...
    '', 'IMC: Demod');
loop = connectBlock( loop, 'IMC: PD Resp', [], [], 0.72, ...
    '', 'IMC: Transimp');
loop = connectBlock( loop, 'IMC: Err Sig', [], [], 0.025, ...
    '', 'IMC: PD Resp');
loop = connectBlock( loop, 'IMC: Cav Pole', [], 8.24e3, 8.24e3, ...
    '', 'IMC: Err Sig');

% Sum point and length and frequency inputs
loop = addNode( loop, 'IMC: Cav Node', 2, 1);
loop = addLink( loop, 'IMC: Cav Node', 'IMC: Cav Pole');
loop = connectBlock( loop, 'IMC: Freq 2 Rad', [], [], 7.344e-7, ...
    '', 'IMC: Cav Node');
loop = connectBlock( loop, 'IMC: Lnt 2 Rad', [], [], 5.905e6, ...
    '', 'IMC: Cav Node');

%% Add Transmitted Frequency Paths
% Frequency to frequency 
loop = addNode( loop, 'IMC: Freq In', 1, 2);
loop = addNode( loop, 'IMC: Freq Out', 2, 1);
loop = addLink( loop, 'IMC: Freq In', 'IMC: Freq 2 Rad');
loop = connectBlock( loop, 'IMC: Cav Pole 2', [], 8.24e3, 8.24e3, ...
    'IMC: Freq In', 'IMC: Freq Out');

% Length to frequency
loop = addNode( loop, 'IMC: Lnt In', 1,2);
loop = addLink( loop, 'IMC: Lnt In', 'IMC: Lnt 2 Rad');
loop = connectBlock( loop, 'IMC: L2F', [], [], 8.041e12, ...
    'IMC: Lnt In', '');
loop = connectBlock( loop, 'IMC: Inv Pole', 0, 8.24e3, 1, ...
    'IMC: L2F', 'IMC: Freq Out');

% Add a sink to the end
loop = connectSink( loop, 'Trans Freq', 'IMC: Freq Out');

%% Connect to Servo and Suspension
loop = addLink( loop, 'IMC: Demod', 'CMS: Gain 1');
loop = addLink( loop, 'MC2: Cav Disp', 'IMC: Lnt In');

%% Insert a Sink and Source between MC2 and the IMC
loop = insertSink( loop, 'Length Out', 'MC2: Cav Disp', ...
    'breakAfter', 1);
loop = insertSource( loop, 'Length In', 'MC2: Cav Disp', ...
    'breakAfter', 1);

%%
%%%------------------------------------------------------------------------
%%% VCO
%%%------------------------------------------------------------------------

% We will work backwards from the output to the input.

%% Build Path
loop = addBlock( loop, 'VCO: Doub', [], [], 2);
loop = connectBlock( loop, 'VCO: Gain', [], [], 2.484e5, ...
    '', 'VCO: Doub');
loop = connectBlock( loop, 'VCO: TF', 2750e3, 275e3, 1/10, ...
    '', 'VCO: Gain');
loop = connectBlock( loop, 'VCO: Filt', 40, 1.6, 1.6/40, ...
    '', 'VCO: TF');

%% Connect to CMS and IMC
loop = addLink( loop, 'CMS: Fast Filt', 'VCO: Filt');
loop = addLink( loop, 'VCO: Doub', 'IMC: Freq In');

%% Insert a Sink and a Source between the VCO and IMC
loop = insertSink( loop, 'PSL Freq', 'VCO: Doub', ...
    'breakAfter', 1);

loop = insertSource( loop, 'Freq Noise', 'VCO: Doub', ...
    'breakAfter', 1);


%%
%%%------------------------------------------------------------------------
%%% Insert Noise Inputs
%%%------------------------------------------------------------------------

%% Insert a Radiation Pressure Source in front of MC2:M3i
loop = insertSource( loop, 'Radiation Pressure', 'MC2: M3i');

%% Insert a Shot Noise Source 
% The shot noise is assumed to be in terms of current noise so we will
% insert the source in front of the transimpedance gain.
loop = insertSource( loop, 'Shot Noise', 'IMC: Transimp');

%% Insert a VCO Noise Source
% The VCO noise is expressed in terms of frequency noise at the output of
% the VCO.  We will put it in front of the AOM doubling gain in the model.
loop = insertSource( loop, 'VCO Noise', 'VCO: Doub');

%% Insert a BOSEM Noise Source
% The BOSEM sensing noise is expressed in terms of length noise so we will
% insert the source in front of the damping filters.  
loop = insertSource( loop, 'BOSEM Noise', 'MC2: Damp');

%% Insert a Dark Noise Source
loop = insertSource( loop, 'Dark Noise', 'CMS: Gain 1');























