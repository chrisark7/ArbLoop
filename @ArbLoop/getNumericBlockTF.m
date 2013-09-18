% ArbLoop Method: Level 2
%
%   This function gets the numerical transfer function from a numeric block
% (i.e. those added with addBlockNumeric).  If the frequency vector
% requested is the same as the the frequency vector that was given to the
% block, then it will simply pass back the stored resp.  
% 
% Otherwise it will use a Matlab interpolation algorithm to interpolate the
% response onto the requested frequency vector.  The interpolation method
% uses spline interpolation which will extrapolate beyond the given data,
% but it should not be trusted well beyond the data limits.  
% 
% 
% Example: 
% resp = getNumericBlockTF( loop, {'block', sn}, f)

function resp = getNumericBlockTF( loop, arg, f)

%% Error Checking of Inputs

% Is arg in the correct form
if ~ (length(arg) == 2)
    error( 'getNumericBlockTF:badarg', ['Block identifier should be in ' ...
        'the {''block'', sn} form'])
end
if ~ strcmp( arg{1}, 'block')
    error( 'getNumericBlockTF:badarg', 'arg type should be block');
end

blType = 'block';
blSn = arg{2};

% Is the block numeric?
if ~ loop.block(blSn).isNum
    error( 'getNumericBlockTF:badarg', 'Specified block is not numeric');
end

% Is f a column vector?
nowSz = size(f);
if ~ (nowSz(1) == length(f))
    f = f';
    nowSz = size(f);
end
if ~ (nowSz(2) == 1)
    error('addBlockNumeric:badf', 'f should be a vector')
end

%% Check if the Requested f is equal to the block f

blF = loop.block(blSn).f;
blResp = loop.block(blSn).resp;

% First check the lengths
if ~ ( length(blF) == length(f))
    blInt = 1;
elseif ~all( blF == f)
    blInt = 1;
else
    blInt = 0;
    resp = blResp;
end

%% Interpolate if Necessary
if blInt
    resp = interp1( blF, blResp, f, 'spline');
end








