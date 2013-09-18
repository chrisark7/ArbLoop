% This function is used to plot phase on a Bode plot.  It differs from the
% standard semilogx plot in that it looks for the points where the phase
% jumps from +180 to -180 and prevents the plot function from plotting a
% vertical line at that point.  This is particularly useful for plotting
% transfer functions with very active phase.
%     plotPhs also passes all arguments after the first two on to the plot
% command.  I.E. one can still specify the color and linewidth as normal.

function plotPhs(f, phs, varargin)

% Check Length and Convert to Columns
szf = size(f);
szp = size(phs);

if ~length(f) == length(phs)
    error('Arguments should be the same length')
end

if szf(1) == 1
    f = f';
elseif szp(1) == 1
    phs = phs';
end


%% Understand the Breaks
mx = max(phs);
mn = min(phs);
rng = range(phs);
cent = mn + rng/2;

lnt = length(phs);
phsShift = zeros( size( phs));
phsShift(1) = phs(1);
phsShift(2:lnt) = phs(1:lnt-1);


ints = find( abs(phsShift - phs) > rng/5 );

%% Plots
lnt2 = length(ints);
holdState = ishold;

if lnt2 == 0
    semilogx( f, phs, varargin{:})
%     ylim([mn mx])
else
    for jj = 1:lnt2+1
        if jj == 1
            nowInt1 = 1;
            nowInt2 = ints(jj) - 1;
        elseif jj == lnt2+1
            nowInt1 = ints(jj-1);
            nowInt2 = lnt;
        else
            nowInt1 = ints(jj - 1);
            nowInt2 = ints(jj) - 1;
        end
        % Decide if the ends are high or low
        nowF = vertcat(f(nowInt1), f(nowInt1:nowInt2), f(nowInt2));
        if phs(nowInt1) > cent
            if phs(nowInt2) > cent
                nowPhs = vertcat(mx, phs(nowInt1:nowInt2), mx);
            else
                nowPhs = vertcat(mx, phs(nowInt1:nowInt2), mn);
            end
        else
            if phs(nowInt2) > cent
                nowPhs = vertcat(mn, phs(nowInt1:nowInt2), mx);
            else
                nowPhs = vertcat(mn, phs(nowInt1:nowInt2), mn);
            end
        end
        semilogx(nowF, nowPhs, varargin{:})
        if ~holdState
            hold on
        end
    end
%     ylim([mn mx])
end

    
