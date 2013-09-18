

function varargout = bodeBlock(f, h, varargin)



mag = 20*log10( abs(h));
phs = 180/pi * angle(h);

if nargout == 1
    varargout(1) = {mag};
elseif nargout == 2
    varargout(1) = {mag};
    varargout(2) = {phs};
end

if (nargin < 3) && (nargout > 0)
    return
else
    
    figure;
    lnWdth = 2;
    fntSz = 12;

    subplot(2,1,1)
    set(gca,'FontSize',fntSz)
    semilogx(f, mag,...
        'LineWidth', lnWdth)
    grid on
    title('Filter Response')
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    xlim([min(f) max(f)])
    ylim([floor(min(mag))-1 ceil(max(mag))+1])

    subplot(2,1,2)
    set(gca,'FontSize',fntSz)
    semilogx(f, phs,...
        'LineWidth', lnWdth)
    grid on
    xlabel('Frequency (Hz)')
    ylabel('Magnitude (dB)')
    xlim([min(f) max(f)])
    ylim([-182 182])

end