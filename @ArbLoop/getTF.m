% ArbLoop Method: Level 3
% 
%    This function is the main interaction function for ArbLoop.  It 
% calculates the transfer function of the model from a 
% specified source to a specified sink.  As with most of the other ArbLoop 
% functions it can take either the name or the type and sn of the 
% source/sink.  
%    Conceptually, the algorithm works by defining the output of every 
% summing junction as a variable.  It then gets the backwards maps from
% each of these variables (and the output) to each of these variables (and
% the input).  These maps are stored in an (Nvar + 1) x (Nvar + 2) x
% length(f) matrix, and row reduction is used to solve the system of
% equations at every frequency point.  
%    If we define the output of every summing junction as ui, the tf source 
% as a, and the tf sink as b, then the equations take the matrix form
% |0|   | 1 x x x . . x x |   |b |
% |0|   | 0 x x x . . x x |   |u1|
% |0|   | 0 x x x . . x x |   |u2|
% |0| = | 0 x x x . . x x | * |u3|
% |.|   | 0 x x x . . x x |   |u4|
% |.|   | 0 x x x . . x x |   |. |
% |0|   | 0 x x x . . x x |   |. |
%                             |a |
% After the matrix is in reduced row eschelon form, the response at the
% specified frequency is given simply by -1 times the coefficeint in the
% upper right corner of the matrix.  
%
% Input Arguments:
% loop: the ArbLoop structure
% sourceName: the transfer function source
% sinkName: the transfer function sink
% f: the frequency vector over which to calculate the transfer function
% tol: (optional) the tolerance for row reduction. See the rref 
%      documentation for more information.  
%
% Output Arguments:
% resp: the response at the specified frequencies
% rnk: the percieved rank of the rref algorithm at each frquency point.
%      See the rref documentation for more information.
% 
% Example:
% [resp, rnk] = getTF( loop, sourceName, sinkName, f, tol);
% 

function [resp, rnk] = getTF(loop, sourceName, sinkName, f, varargin)

%% Parse Inputs

for jj = 1:2
    switch jj
        case 1
            name = sourceName;
        case 2
            name = sinkName;
    end
    
    if ischar(name)
        kk = find( strcmp( name, {loop.reg.name}));
        if isempty(kk)
            error('getTF:badInput', 'One of the specified components doesn''t seem to exist')
        end
        now.type = loop.reg(kk).type;
        now.sn = loop.reg(kk).sn;
    else
        now.type = name{1};
        now.sn = name{2};
    end
    switch jj
        case 1
            argin = now;
            if ~strcmp(argin.type, 'source')
                error('getTF:badIn', 'Specified component should be a source')
            end
        case 2
            argout = now;
            if ~strcmp(argout.type, 'sink')
                error('getTF:badIn', 'Specified component should be a sink')
            end
    end
end


%% Generate the Points for the Equation Matrix
% Get all of the nodes which have sums
inPnt = genSplitNodes(loop);
outPnt = inPnt;

% Add the input to the in pnts and the output to the out pnts
inPnt = horzcat( inPnt, {{argin.type, argin.sn}});
outPnt = horzcat( {{argout.type, argout.sn}}, outPnt);

lnt = length(outPnt);

%% Build the Equation Matrix
mat = zeros(lnt, lnt + 1, length(f));

% Ones on the Diagonal
for jj = 1:lnt
    mat(jj, jj, :) = ones(1,1,length(f));
end

% Add Transfer Functions
for jj = 1:lnt
    nowOut = outPnt{jj};
    %Generate the maps from all of the inPnt to this particular outPnt
    nowMap = genMapFromTo( loop, inPnt, nowOut);
    for kk = 1:lnt
        %Calculate the TF of each and sum parallel loops
        nowTF = zeros( length(f), 1);
        for ll = 1:length( nowMap(kk).map)
            nowTF = nowTF + getMapTF( loop, nowMap(kk).map(ll), f);
        end
        mat(jj, kk + 1, :) = mat( jj, kk + 1, :) - ...
            shiftdim( nowTF, -2);
    end
end

% Set NaN values to zero
mat(isnan(mat)) = 0;



%% Numerical Row Reduction Using rref
% Timing and wait bar initialization
t0 = tic;
lnt2 = length(f);
waitH = waitbar( 0, 'Row Reducing. Apx. Time Left: NA',...
    'Name', 'ArbLoop: Computing TF', ...
    'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)');
setappdata(waitH, 'canceling', 0);

% rref tolerance
if nargin > 4
    tol = varargin{1};
else
    tol = 1e-30;
end

rnk = zeros( length(f), 1);
for jj = 1:lnt2
    %Cancel if the window is closed.
    if getappdata( waitH, 'canceling')
        delete(waitH)
        error('getTF:canceled', 'TF computation canceled by user');
    end
    [mat(:,:,jj), nowRnk] = rref( mat(:,:,jj), tol);
    rnk(jj) = length(nowRnk);
    %Update wait bar every so often
    if mod(jj,5) == 0
        %Calculate time left
        nowTime = toc( t0)/jj * (lnt2 - jj);
        %Update wait bar
        waitbar( jj/lnt2, waitH,...
            ['Row Reducing. Apx. Time Left: ' sprintf('%1.0f', nowTime) ' s'])
    end
end
delete(waitH)

%% Pick Out the Correct TF 
resp = -1*squeeze( mat(1, end, :));


%% Check for Matrix Rank and Tolerance Issues

%Is the solution not full rank at every frequency point?
if sum( ~( rnk == lnt)) > 0
    %Is it the same rank at every frequency point but not full rank?
    if sum( ~( rnk == rnk(1))) > 0 
         warning( 'getTF:badRank1', ...
             ['Equation matrix appears to be rank deficient at all ' ...
             'frequencies indicating a linear dependence among the ' ...
             'derived equations.  Check for linear dependent paths ' ...
             'in the loop structure.  Note that this is not uncommon' ...
             'when paths are broken such as when calculating an OLTF']);
    else
        warning( 'getTF:badRank2', ...
            ['Equation matrix appears to be rank deficient at some ' ...
            'frequency points likely indicating a numerical problem ' ...
            'with the row reduction procedure.  Try reducing the ' ...
            'rref tolerance (optional argument to getTF) at the cost ' ...
            'of speed.  Alternatively the problem can be with ' ...
            'sresp returning NaNs (which get set to zero) ' ...
            'for individual filter responses'])
    end
end

%Are some of the response points identically zero
if sum( resp == 0) > 0
    warning( 'getTF:badTol', ...
        ['The response is identically zero at ' ...
        sprintf('%1.0d', sum( resp == 0)) ...
        ' of the frequency points.  This is possibly due to the ' ...
        'default tolerance of the rref function being set too low. ' ...
        'Try reducing the tolerance by passing an optional argument ' ...
        'to getTF.  Alternatively, it can be due to double precision ' ...
        'errors when sresp calculates the frequency response of ' ...
        'individual filters.  Be leary of the results.'])
end















