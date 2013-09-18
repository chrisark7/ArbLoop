% ArbLoop Method: Level 1
%
% Add a transfer function block to an ArbLoop object.  The function takes
% in any (I think) form of transfer function definable by matlab and
% converts it to an Evans filter object (z, p, k stored as seperate fields)
% and stores it in the specified ArbLoop object.  The prefered method is to
% pass it z, p, k as three seperate arguments so that there is no loss of
% accuracy in the conversion process.  
% 
% Note: mf filters store the zs and ps as positive numbers in units of
% Hertz.  One therefore does not have to remember to add a -2*pi in front
% of the zs and ps.  Use the checkBlockTF function to check that the block
% transfer function is as expected. 
%
% A block has the following fields:
% -------- These are added with addBlock i.e. this function ---------------
% name - the name of the block (string)
% sn - the serial number of the block (double or int)
% z - the zeros of the transfer function (column vector)
% p - the poles of the transfer function (column vector)
% k - the gain of the transfer function (double)
% isNum - tells ArbLoop if the transfer function is numeric, and is set to 
%     0 with this function.  Use addBlockNumeric to add a numeric TF.
% f - frequency vector for numeric blocks, left empty by this function.
% resp - response vector for numeric blocks, left empty by thei function.
% ------------- These are added with addLink ------------------------------
% inName - the name of the object connected to the input (string)
% inType - the type of object connected to the input (string)
% inNum - the sn of the object connected to the input (double or int)
% outName - the name of the object connected to the output (string)
% outType - the type of object connected to the output (string)
% outNum - the sn of the object connected to the output (double or int)
% 
% 
% Examples:
% 
% loop = addBlock(loop, name, z, p, k);          (Preferred)
% loop = addBlock(loop, name, zpk(z, p, k));
% loop = addBlock(loop, name, ss(a, b, c, d));

function [loop, sn] = addBlock(loop, name, varargin)

sn = loop.Nblock + 1;
loop.Nblock = sn;

switch nargin
    case 0:2
        error('addBlock:moreArgs','This function needs args')
    case 3
        nowArg = varargin{1};
        if isstruct(nowArg)
            sysident = 0;
            z = nowArg.z;
            p = nowArg.p;
            k = nowArg.k;
        else            
            sysident = 1;
            sys = nowArg;
        end
    case 4
        error('addBlock:notSure', 'Not sure how to handle these arguments')
    case 5
        sysident = 0;
        z = varargin{1};
        p = varargin{2};
        k = varargin{3};
    otherwise
        warning('addBlock:lessArgs', 'Too many arguments. Ignoring all but 5')
        sysident = 0;
        z = varargin{1};
        p = varargin{2};
        k = varargin{3};
end

if sysident %Get z and p from sys
    sysClass = class(sys);
    if strcmp( sysClass, 'ss')
        [a, b, c, d] = ssdata(sys);
        [z, p, k] = ss2zp(a, b, c, d, 1);
        z = -1/(2*pi)*z(:,1);
        p = -1/(2*pi)*p(:,1);
        zpDif = numel(p) - numel(z);
        k = k * (2*pi)^(-zpDif);        
    else
        [z, p, k] = zpkdata( sys);
        z = -1/(2*pi)*z{:,1};
        p = -1/(2*pi)*p{:,1};
        zpDif = numel(p) - numel(z);
        k = k * (2*pi)^(-zpDif);  
    end
else %Check that z and p are column vectors
    if size(z, 2) ~= 1
        z = z';
    end
    if size(p, 2) ~= 1
        p = p';
    end
    if numel(k) ~= 1
        k = prod(k);
        warning('addBlock:badGain', 'More than 1 gain specified; multiplying')
    end
end

if sum( z < 0 ) > 0
    warning('addBlock:badFilt', 'Specified filter has right half plane zeros. Remember this is an Evans filter.')
elseif sum( p < 0) > 0
    warning('addBlock:badFilt', 'Specified filter has right half plane poles. Remember this is an Evans filter.')
end

loop.block(sn, 1).sn = sn;
loop.block(sn, 1).name = name;
loop.block(sn, 1).z = z;
loop.block(sn, 1).p = p;
loop.block(sn, 1).k = k;
loop.block(sn, 1).isNum = 0;
loop.block(sn, 1).f = [];
loop.block(sn, 1).resp = [];
loop.block(sn, 1).inName = 'null';
loop.block(sn, 1).inType = 'null';
loop.block(sn, 1).inNum = 0;
loop.block(sn, 1).outName = 'null';
loop.block(sn, 1).outType = 'null';
loop.block(sn, 1).outNum = 0;

% Update Registry
n = loop.Nreg + 1;
loop.Nreg = n;

loop.reg(n).name = name;
loop.reg(n).sn = sn;
loop.reg(n).type = 'block';

end


        
        
    