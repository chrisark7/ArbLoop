% ArbLoop Method: Level 3
% 
%    This function calculates the open loop transfer function at a block
% specified by the user.  The function does so by breaking the loop before
% (or after) the block an inserting an input and an output and then calling
% getTF.  
%    By Default the function breaks the loop before the specified block,
% but an optional argument can be passed to instruct it to break the loop
% after.  
%
% Input Arguments:
% loop: the ArbLoop model.
% name: the block where the OLTF will be calculated.  
% f: the freqeucny points at which to calculate the OLTF.
%
% Optional Input Arguments:
% breakAfter: 0 or 1 (default 0)
% noTF: 0 or 1 (default 0)  supresses calculation of the transfer function
%    and returns an empty resp vector.  This is useful for continually
%    breaking the ArbLoop model at a number of points.
% tolerance: tolerance to pass to getTF.
%
% Output Arguments
% resp: the complex response at the given frequency points.
% loop2: the modified loop structure.  This can be useful with the noTF
%    option to break the model in a number of places to get different OLTFs
% nameIn: the name of the source created by the function.  Useful for
%    calculating the transfer function at this point after other breaks.
% nameOut: the name of the sink created by the function.  Useful for
%    calculating the transfer function at this point after other breaks.
%
% Examples:
% resp = getOLTF( loop, 'Block 1', freq_vec, 'breakAfter', 1)
% resp = getOLTF( loop, {'block' 3}, f)
% resp = getOLTF( loop, 'Controller 3', freq, 'breakAfter', 0) 
% [resp, loop2, nameIn, nameOut] = getOLTF( loop, 'Block 10', f,...
%         'noTF', 1, 'breakAfter', 1, 'tolerance', 1e-12);
% 
% Usage: 
% [resp, loop2, nameIn, nameOut] = getOLTF( loop, name, f, varargin);

function [resp, loop2, nameIn, nameOut] = getOLTF( loop, name, f, varargin)

%% Parse Inputs
if ischar(name)
    kk = find( strcmp( name, {loop.reg.name}));
    if isempty(kk)
        error('getOLTF:badInput', 'The specified components doesn''t seem to exist')
    end
    nowType = loop.reg(kk).type;
    nowSn = loop.reg(kk).sn;
    nowName = loop.reg(kk).name;
else
    nowType = name{1};
    nowSn = name{2};
    nowName = loop.(nowType)(nowSn).name{1};
end

%Optional arguments
%Defaults
noTF = 0;
breakAfter = 0;
tol = 0;
if nargin > 3
    %Optional Arguments should come in pairs
    if ~(mod( nargin - 3, 2) == 0)
        warning('getOLRG:badOptArg', ...
            'Unable to understand optional argumants, continuing with defaults')
        breakAfter = 0;
    else
        for jj = 1:(length(varargin)/2)
            if strcmp( varargin{2*jj-1}, 'breakAfter')
                breakAfter = varargin{2*jj};
            elseif strcmp( varargin{2*jj-1}, 'noTF')
                noTF = varargin{2*jj};
            elseif strcmp( varargin{2*jj-1}, 'tolerance')
                tol = varargin{2*jj};
            else
                warning('getOLRG:badOptArg', ...
                    'Unable to understand optional argumants, continuing with defaults')
                breakAfter = 0;
                noTF = 0;
            end
        end
    end
end
        

%Reject sinks, sources, or nodes 
if strcmp( nowType, 'sink')
    error('getLoopOLTF:badIn', 'Input should not be a sink')
elseif strcmp( nowType, 'source')
    error('getLoopOLTF:badIn', 'Input should not be a source')
elseif strcmp( nowType, 'node')
    error('getLoopOLTF:badIn', 'Input Should not be a node')
end

%% Break the Loop and Insert a Sink and Source
loop2 = loop;

%Get Forward and Backward Objects
if breakAfter
    %Get this object
    bckType = nowType;
    bckSn = nowSn;
    bckName = nowName;
    bckObj = loop.(nowType)(nowSn);
    %What is connected to the back of this object
    frwType = bckObj.outType;
    frwSn = bckObj.outNum;
    frwName = bckObj.outName;
    frwObj = loop.(frwType)(frwSn);
else
    %Get this object
    frwType = nowType;
    frwSn = nowSn;
    frwName = nowName;
    frwObj = loop.(nowType)(nowSn);
    %What is connected in front of this block
    bckType = frwObj.inType;
    bckSn = frwObj.inNum;
    bckName = frwObj.inName;
    bckObj = loop.(bckType)(bckSn);
end

%Check if the objects are nodes
if strcmp( frwType, 'node')
    frwObj.inName;
    bckName;
    ndSn = find( strcmp( frwObj.inName, bckName));
    frwCon = {frwType, frwSn, ndSn};
else
    frwCon = {frwType, frwSn};
end
if strcmp( bckType, 'node')
    ndSn = find( strcmp( bckObj.outName, frwName));
    bckCon = {bckType, bckSn, ndSn};
else
    bckCon = {bckType, bckSn};
end

%Choose Name for Sink and Source
nameFound = 0;
nameNum = 1;
while nameFound == 0
    nameIn = ['OLTF In ' sprintf('%1.0d', nameNum)];
    nameOut = ['OLTF Out ' sprintf('%1.0d', nameNum)];
    if sum( strcmp( {loop2.reg.name}, nameIn)) || sum( strcmp( {loop2.reg.name}, nameOut))
        nameNum = nameNum + 1;
    else
        nameFound = 1;
    end
end

%Overwrite output of bckObj with a sink
loop2 = addSink( loop2, nameOut);
loop2 = addLink( loop2, bckCon, nameOut, ...
    'supressWarn', 1);
%Overwrite input of frwObj with a source
loop2 = addSource( loop2, nameIn);
loop2 = addLink( loop2, nameIn, frwCon, ...
    'supressWarn', 1);

%% Get TF
if noTF
    resp = [];
elseif ~tol
    resp = getTF( loop2, nameIn, nameOut, f);
else
    resp = getTF( loop2, nameIn, nameOut, f, tol);
end

    
    
    




































    

