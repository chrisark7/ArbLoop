% ArbLoop Method: Level 1
%
% Add a numerical transfer function block to an ArbLoop object.  When this 
% block is processed in the end it will interpolate the transfer function
% if necessary.  For speed it is recommended to store the numerical
% transfer functions with the same frequency vector as will be used in the
% end if possible.  
%
% This block is useful for including realistic transfer functions that are
% not easily expressed in zpk form such as delays and optical transfer
% functions.  It can also be used to include measured data.  
%
% A block has the following fields:
% -------- These are added with addBlockNumeric i.e. this function --------
% name - the name of the block (string)
% sn - the serial number of the block (double or int)
% z - the zeros of the transfer function (empty for numeric TFs)
% p - the poles of the transfer function (empth for numeric TFs)
% k - the gain of the transfer function (1 for numeric TFs)
% isNum - tells ArbLoop if the transfer function is numeric, and is set to 
%     1 with this function
% f - frequency vector for numeric blocks
% resp - response vector for numeric blocks
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
% tau = 1;
% f = logspace( -1, 4, 1000);
% resp = exp( -1i*2*pi*f*tau);
% loop = addBlock( loop, name, f, resp); 

function [loop, sn] = addBlockNumeric(loop, name, f, resp)

%% Check the Inputs
% Check that f and resp are column vectors
nowSz = size(f);
if ~ (nowSz(1) == length(f))
    f = f';
    nowSz = size(f);
end
if ~ (nowSz(2) == 1)
    error('addBlockNumeric:badf', 'f should be a vector')
end

nowSz = size(resp);
if ~ (nowSz(1) == length(resp))
    resp = resp';
    nowSz = size(resp);
end
if ~ (nowSz(2) == 1)
    error('addBlockNumeric:badresp', 'resp should be a vector')
end

% Check that they are the same size
if ~ (length(f) == length(resp))
    error('addBlockNumeric:badArgs', 'f and resp should be the same length')
end

%% Build Block

sn = loop.Nblock + 1;
loop.Nblock = sn;

loop.block(sn, 1).sn = sn;
loop.block(sn, 1).name = name;
loop.block(sn, 1).z = [];
loop.block(sn, 1).p = [];
loop.block(sn, 1).k = 1;
loop.block(sn, 1).isNum = 1;
loop.block(sn, 1).f = f;
loop.block(sn, 1).resp = resp;
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


        
        
    