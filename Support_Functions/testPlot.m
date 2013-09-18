
f = logspace( -1, 6, 5000);


testguy = mc2ss( mc2out.m3.disp.L, mc2in.gnd.disp.L );

arbobj = 'Gnd Resp';

arbresp = sresp( loop, arbobj, f);
[arbmag, arbphs] = bodeBlock(f, arbresp, 1);


testresp = squeeze(freqresp(testguy, 2*pi*f));
[testmag, testphs] = bodeBlock(f, testresp, 1);





lnWdth = 2;
fntSz = 12;

figure(1)
subplot(2,1,1)
set(gca,'FontSize',fntSz)
semilogx(f, testmag-1,...
    'LineWidth', lnWdth,...
    'Color', 'r')
hold on
semilogx(f, arbmag,...
    'LineWidth', lnWdth,...
    'Color', 'b')
hold off
grid on
title('Filter Response')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([min(f) max(f)])
ylim([floor(min(arbmag))-1 ceil(max(arbmag))+1])

subplot(2,1,2)
set(gca,'FontSize',fntSz)
semilogx(f, testphs,...
    'LineWidth', lnWdth,...
    'Color', 'r')
hold on
semilogx(f, arbphs,...
    'LineWidth', lnWdth,...
    'Color', 'b')
hold off
grid on
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([min(f) max(f)])
ylim([-182 182])
