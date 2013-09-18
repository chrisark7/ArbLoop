
%% Some Useful Parameters
clight = 2.99e8; %[m/s]
lambda = 1.064e-6; %[m]
modndx = 0.1; %[1] Modulation Index
p0 = 25; %[W] Input Power

%% Load Suspensions and Make Damping Filters
load sus.mat

sus.damp = zpk([0], -2*pi*[15+1i*25.9808 15-1i*25.9808], ...
    abs(2*pi*(15+1i*25.9808))^2);

% Damping Gains
sus.gain.hsts = -10;
sus.gain.hlts = -20;
sus.gain.bsfm = -10;
sus.gain.quad = -50;

% Inversion Filters
sus.hsts.inv.z = -2*pi*[0.79; 0.79];
sus.hsts.inv.p = -2*pi*[1e3; 1e3];
sus.hsts.inv.k = (1e3/0.79)^2;

sus.quad.inv.z = -2*pi*0.71*ones(4,1);
sus.quad.inv.p = -2*pi*1e3*ones(4,1);
sus.quad.inv.k = (1e3/0.71)^4;




%% PD Response
pd.resp = 0.72; %[A/W] Apx. Responsivity from c30642 datasheet 
pd.gainV = 155; %[V/A] D1200662-v2
pd.gainC = 1.838e4; %[cnts/V] (total signal chain) D1200622-v2


%% IMC SubModel
imc.l = 34.9462; % [m] IMC round trip length
imc.r = sqrt(0.994); % [1] MC1 and MC3 reflectivity
imc.p = clight/imc.l*(1-imc.r^2)/imc.r^2; % [Hz] IMC cavity pole
imc.aten = 0.02; % [1] Attenuation of IMC light to PD
imc.errsig = imc.aten*modndx*p0*imc.r/(1+imc.r^2); %[W] IMC error signal slope

imc.pdresp = 0.72; %[A/W] from c30642 datasheet
imc.ztrans = 460; %transimpedance at 24.5MHz [ohms] (T1200334)
imc.demod = 10; % Demodulator conversion gain.  (measured)

imc.sw.runacq = 0; %0 is run, 1 is acqire
imc.sw.lp = 1; %0 is no lp, 1 is with lp

% Close Testing Switches
imc.sw.freq = 1;
imc.sw.m3 = 1;
imc.sw.m2 = 1;
imc.sw.m1 = 1;
imc.sw.ovl = 1;
imc.sw.ltot = 1;

% Load IMC Length Filters
load IMC_Filters.mat











































