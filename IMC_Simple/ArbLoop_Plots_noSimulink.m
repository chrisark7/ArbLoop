% This script extracts some transfer functions from the ArbLoop model
% ArbLoop_IMC_Simple and compares them to the Simulink model IMC.mdl on
% which the ArbLoop model is based.
clear all

addpath('../Support_Functions/')
%% Load and Initialize the ArbLoop Model
% Load the model.  The ArbLoop object created has the variable name loop.
ArbLoop_IMC_Simple

% Check that all of its blocks are connected (displays to the workspace)
checkLoop(loop)

% Display all of the components contained in the model and their
% connections.
loop

% Define a frequency vector for the transfer functions
f = logspace(-2, 6, 1000);

% Load Simulink model
Generate_IMC_Simulink
imc.sw.freq = 0;
imc.sw.m1 = 0;
imc.sw.m2 = 0;
imc.sw.m3 = 0;
[temp.a temp.b temp.c temp.d] = linmod( 'IMC');
sim.ss = ss( temp.a, temp.b, temp.c, temp.d);


%% Get Open Loop Transfer Functions
% The command getOLTF extracts an open loop transfer function by breaking
% the loop at the specified point, inserting a sink and a source, and then
% calculating the transfer function with getTF.  If, as in this case, it is
% desirable to break the loop in multiple places before calculating the
% transfer functions the broken ArbLoop model can be passed out and passed
% again to getOLTF.
[~, loop2, m1.nameIn, m1.nameOut] = getOLTF( loop, 'MC2: M1 DAC', f, ...
    'noTF', 1);
[~, loop2, m2.nameIn, m2.nameOut] = getOLTF( loop2, 'MC2: M2 DAC', f, ...
    'noTF', 1);
[~, loop2, m3.nameIn, m3.nameOut] = getOLTF( loop2, 'MC2: M3 DAC', f, ...
    'noTF', 1);
[arb.freq.resp, loop2, freq.nameIn, freq.nameOut] = getOLTF( loop2, ...
    'VCO: Filt', f);
arb.m1.resp = getTF( loop2, m1.nameIn, m1.nameOut, f);
arb.m2.resp = getTF( loop2, m2.nameIn, m2.nameOut, f);
arb.m3.resp = getTF( loop2, m3.nameIn, m3.nameOut, f);

% Get the Simulink TFs
sim.freq.resp = squeeze( freqresp( sim.ss(4,3), 2*pi*f));
sim.m1.resp = squeeze( freqresp( sim.ss(7,6), 2*pi*f));
sim.m2.resp = squeeze( freqresp( sim.ss(6,5), 2*pi*f));
sim.m3.resp = squeeze( freqresp( sim.ss(5,4), 2*pi*f));

% Convert to magnitude and phase
typ = {'freq', 'm1', 'm2', 'm3'};
for jj = 1:length(typ)
    arb.(typ{jj}).mag = 20*log10( abs( arb.(typ{jj}).resp));
    arb.(typ{jj}).phs = 180/pi*angle( arb.(typ{jj}).resp);
    sim.(typ{jj}).mag = 20*log10( abs( sim.(typ{jj}).resp));
    sim.(typ{jj}).phs = 180/pi*angle( sim.(typ{jj}).resp);
end

% Plot
lnwt = 2;
fntsz = 10;
clr = colors(length(typ));

figure(1)
clf
subplot(211)
set(gca, 'FontSize', fntsz)
semilogx( f, arb.freq.mag, 'Color', clr(1,:), 'LineWidth', lnwt)
hold on
% semilogx( f, sim.freq.mag-10, '--', 'Color', clr(1,:), 'LineWidth', lnwt)
for jj = 2:length(typ)
    semilogx( f, arb.(typ{jj}).mag, 'Color', clr(jj,:), 'LineWidth', lnwt)
%     semilogx( f, sim.(typ{jj}).mag-10, '--', 'Color', clr(jj,:), ...
%         'LineWidth', lnwt)
end
hold off
grid on
ylim([-50 200])
ylabel('Transfer Function Magnitude (dB)')
title('Open Loop Transfer Functions', 'FontSize', fntsz + 2)
legend('Frequency', 'Top Mass', 'Middle Mass', 'Mirror')

subplot(212)
set(gca, 'FontSize', fntsz)
plotPhs( f, arb.freq.phs, 'Color', clr(1,:), 'LineWidth', lnwt)
hold on
% plotPhs( f, sim.freq.phs-10, '--', 'Color', clr(1,:), 'LineWidth', lnwt)
for jj = 2:length(typ)
    plotPhs( f, arb.(typ{jj}).phs, 'Color', clr(jj,:), 'LineWidth', lnwt)
%     plotPhs( f, sim.(typ{jj}).phs-10, '--', 'Color', clr(jj,:), ...
%         'LineWidth', lnwt)
end
hold off
grid on
ylabel('Transfer Function Phase (deg)')
xlabel('Frequency (Hz)')
ylim([-180 180])

orient landscape 
print -dpdf Open_Loop_TFs.pdf

%% Get Closed Loop TFs

% Reload Simulink Model
imc.sw.freq = 1;
imc.sw.m1 = 1;
imc.sw.m2 = 1;
imc.sw.m3 = 1;
[temp.a temp.b temp.c temp.d] = linmod( 'IMC');
sim.ss = ss( temp.a, temp.b, temp.c, temp.d);

% Get ArbLoop Tfs
arb.lnt.resp = getTF( loop, 'Length In', 'Length Out', f);
arb.frq.resp = getTF( loop, 'Freq Noise', 'PSL Freq', f);
arb.seis2tf.resp = getTF( loop, 'ISI Disp', 'Trans Freq', f);
arb.freq2tf.resp = getTF( loop, 'Freq Noise', 'Trans Freq', f);

% Get Simulink TFs
sim.lnt.resp = squeeze( freqresp( sim.ss(12,11), 2*pi*f));
sim.frq.resp = squeeze( freqresp( sim.ss(3,10), 2*pi*f));
sim.seis2tf.resp = squeeze( freqresp( sim.ss(1,7), 2*pi*f));
sim.freq2tf.resp = squeeze( freqresp( sim.ss(1,10), 2*pi*f));

% Convert to Magnitude and Phase
typ2 = {'lnt', 'frq', 'seis2tf', 'freq2tf'};
for jj = 1:length(typ2)
    arb.(typ2{jj}).mag = 20*log10( abs( arb.(typ2{jj}).resp));
    arb.(typ2{jj}).phs = 180/pi*angle( arb.(typ2{jj}).resp);
    sim.(typ2{jj}).mag = 20*log10( abs( sim.(typ2{jj}).resp));
    sim.(typ2{jj}).phs = 180/pi*angle( sim.(typ2{jj}).resp);
end

% Plot
clr = colors(length(typ2));

figure(2)
clf
subplot(211)
set(gca, 'FontSize', fntsz)
semilogx( f, arb.lnt.mag, 'Color', clr(1,:), 'LineWidth', lnwt)
hold on
semilogx( f, sim.lnt.mag-10, '--', 'Color', clr(1,:), 'LineWidth', lnwt)
for jj = 2:length(typ2)
    semilogx( f, arb.(typ2{jj}).mag, 'Color', clr(jj,:), 'LineWidth', lnwt)
    semilogx( f, sim.(typ2{jj}).mag-10, '--', 'Color', clr(jj,:), ...
        'LineWidth', lnwt)
end
hold off
grid on
ylim([-100 220])
ylabel('Transfer Function Magnitude (dB)')
title('Closed Loop Transfer Functions', 'FontSize', fntsz + 2)
legend('ArbLoop: Length to Length', 'Simulink: Length to Length', ...
    'ArbLoop: Freq to Freq', 'Simulink: Freq to Freq', ...
    'ArbLoop: Seis to Trans Freq', 'Simulink: Seis to Trans Freq', ...
    'ArbLoop: Freq to Trans Freq', 'Simulink: Freq to Trans Freq')

subplot(212)
set(gca, 'FontSize', fntsz)
plotPhs( f, arb.lnt.phs, 'Color', clr(1,:), 'LineWidth', lnwt)
hold on
plotPhs( f, sim.lnt.phs-10, '--', 'Color', clr(1,:), 'LineWidth', lnwt)
for jj = 2:length(typ2)
    plotPhs( f, arb.(typ2{jj}).phs, 'Color', clr(jj,:), 'LineWidth', lnwt)
    plotPhs( f, sim.(typ2{jj}).phs-10, '--', 'Color', clr(jj,:), ...
        'LineWidth', lnwt)
end
hold off
grid on
ylabel('Transfer Function Phase (deg)')
xlabel('Frequency (Hz)')

orient landscape 
print -dpdf Closed_Loop_TFs.pdf




























