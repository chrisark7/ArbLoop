% ArbLoop Method: Level 4 
%
%   This script is originally taken from the lentickle mf directory.  It 
% will evaluate an ArbLoop block in the same way that ArbLoop will 
% evaluate it itself.  I.E. it is intended to be used to double check that
% blocks added by the user are correctly specified.  
%   If an output argument is specified it will give the frequency domain 
% response of the filter.  If no output argument is specified it will
% simply generate a plot of the frequency domain response of the filter.
%
% Examples:
% checkBlockTF( loop, {'block', 3}, f)    (Generates a plot)
% resp = checkBlockTF( loop, 'Controller', f); (Calculates the complex response)
%

function varargout = checkBlockTF(loop, name, f)
   if ischar(name)
       %Search the registry for the identifiers
        kk = find( strcmp( name, {loop.reg.name}));
        if isempty(kk)
            error('sresp:badInput', 'Specified component doesn''t seem to exist')
        end
        bkType = loop.reg(kk).type;
        bkSn = loop.reg(kk).sn;
        bkName = loop.reg(kk).name;
   else
       bkType = name{1};
       bkSn = name{2};
       bkName = loop.(bkType)(bkSn).name;
   end
   
   %Check that specified object is a block
   if ~strcmp( bkType, 'block')
       error('sresp:badInput', 'Specified component should be a block')
   end
   
   % Is the block numeric
if loop.(bkType)(bkSn).isNum
    h = getNumericBlockTF( loop, {'block', bkSn}, f);
else
    mf.z = loop.(bkType)(bkSn).z;
    mf.p = loop.(bkType)(bkSn).p;
    mf.k = loop.(bkType)(bkSn).k;

    % compute response
    [b, a] = zp2tf(-mf.z, -mf.p, mf.k);
    h = polyval(b, 1i * f) ./ polyval(a, 1i * f);

    % check for infinities
    n = find(isinf(f));
    if( ~isempty(n) )
        if( length(mf.p) > length(mf.z) )
          h(n) = 0;
        elseif( length(mf.p) < length(mf.z) )
          h(n) = mf.k * Inf;
        else
          h(n) = mf.k;
        end
    end
end

% if no output, display
if( nargout == 0 )

    mag = 20*log10( abs(h));
    phs = 180/pi * angle(h);

    figure;
    lnWdth = 2;
    fntSz = 12;

    subplot(2,1,1)
    set(gca,'FontSize',fntSz)
    semilogx(f, mag,...
        'LineWidth', lnWdth)
    grid on
    title([bkName ' Response'])
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
else
    varargout{1} = h;
end
