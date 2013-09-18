% ArbLoop Method: Level 1
% 
%   Add a link between any of the ArbLoop objects and another.  The
% specifications can be given as either the object name or the object type
% and sn.  The specification for a node can also include the port
% specification; if no port is specified the first unused port will be
% used; if there are no unused ports the first port will be used.  
%   One must be a little careful with the syntax.  The first argument call
% specifies the block whos output will be connected to the second
% argument's input.  Sources therefore can only be called in the first
% argument, and sinks can only be called in the second argument.  
%   The function prints a warning to the workspace if it is overwriting a
% previous connection.  This can be supressed by passing an optional fourth
% argument.  The warning supression is intended mainly for use by the
% insert functions which will naturally be overwriting connections.  
% 
% Optional Arguments:
% supressWarn: 0 or 1 (default 0)
%  
% 
% Examples:
%
% Connect 'Block 1' output to 'Block 2' input
% loop = addLink(loop, 'Block 1', 'Block 2')
%
% Connect block sn 3 output to 'Output 1' input
% loop = addLink(loop, {'block', 3}, 'Output 1')
% 
% Connect second output of 'Node 1' to input of 'Block 2' 
% loop = addLink(loop, {'Node 1', 2}, 'Block 2')
% 
% Connect 'Block 3' output to next free (or first) input of 'Node 1'
% loop = addLink(loop, 'Block 3', 'Node 1')
% 
% Connect 3rd output of node sn 2 to 4th input of node sn 20
% loop = addLink(loop, {'node', 2, 3}, {'node', 20, 4})


function loop = addLink(loop, in, out, varargin)
%%
%%%------------------------------------------------------------------------
%%% Input Parsing and Checking
%%%------------------------------------------------------------------------

%% Understand the inputs
types = {'node', 'block', 'sink', 'source'};
for jj = 1:2
    switch jj
        case 1
            var = in;
        case 2
            var = out;
    end
    if iscell(var)
        switch length(var)
            case 3 % cell is assumed to be {varType = 'node', varSn, varNode}
                if strcmp( var{1}, 'node') %Ensure that type is node
                    varName = 'find';
                    varType = var{1};
                    varSn = var{2};
                    varNode = var{3};
                else
                    warning('addLink:badIn', 'Arguments are non-standard. Treating the first as a component name')
                    varName = var{1};
                    varType = 'find';
                    varSn = 'find';
                    varNode = 'noNode';
                end
            case 2
                if sum( strcmp( var{1}, types)) == 1 % is first argument a type?
                    if strcmp( var{1}, 'node') % is the type a node
                        varName = 'find';
                        varType = var{1};      % if so cell is assumed to be {varType = 'node', varSn} and node type is set to next.
                        varSn = var{2};
                        varNode = 'next';
                    else                       % if not cell is assumed to be {varType, varSn}, i.e. not a node.
                        varName = 'find';   
                        varType = var{1};
                        varSn = var{2};
                        varNode = 'noNode';
                    end
                else %if not we will assume cell is {varName, varNode}
                    varName = var{1};
                    varType = 'node';
                    varSn = 'find';
                    varNode = var{2};
                end
            otherwise %if not we will treat first argument as a name and ignore the rest (with a warning)
                warning('addLink:badIn', 'Arguments are non-standard. Treating the first as a component name')
                varName = var{1};
                varType = 'find';
                varSn = 'find';
                varNode = 'next';
        end
    elseif ischar(var) % a string is assumed to specify a component name
        varName = var;
        varType = 'find';
        varSn = 'find';
        varNode = 'next';
    else
        error('addLink:badIn', 'Unable to understand arguments')
    end
    switch jj
        case 1
            argin.name = varName;
            argin.type = varType;
            argin.sn = varSn;
            argin.node = varNode;
        case 2
            argout.name = varName;
            argout.type = varType;
            argout.sn = varSn;
            argout.node = varNode;
    end            
end

%Parse Optional Arguments
if nargin > 3
    %Optional Arguments should come in pairs
    if ~(mod( nargin - 3, 2) == 0)
        warning('getOLRG:badOptArg', ...
            'Unable to understand optional argumants, continuing with defaults')
        supressWarn = 0;
    elseif strcmp( varargin{1}, 'supressWarn')
        supressWarn = varargin{2};
    else
        warning('getOLRG:badOptArg', ...
            'Unable to understand optional argumants, continuing with defaults')
        supressWarn = 0;
    end
else
    supressWarn = 0;
end
       


%% Check for Consistency
for jj = 1:2
    switch jj
        case 1
            var = argin;
        case 2
            var = argout;
    end
    if ~ strcmp( var.type, 'find')% If type is not 'find'
        if ~( sum( strcmp( var.type, types)) == 1) % Check that type is a type
            error('addLink:badType', 'Type isn''t understandable')
        end
    elseif ~strcmp( var.sn, 'find') % If sn is not find
        if ~isa( var.sn, 'double') % Check that SN is a number
            error('addLink:badSN', 'SN isn''t understandable')
        end
    elseif ~strcmp( var.name, 'find') % If name is not find
        if ~( sum( strcmp( var.name, {loop.reg.name}))) %Check hat name exists
            error('addLink:badName', 'Name is unknown')
        end
    end
end

%% Get the Other Infos from the Registry
for jj = 1:2
    switch jj
        case 1
            var = argin;
        case 2
            var = argout;
    end
    if strcmp( var.sn, 'find') %Name is assumed to be known
        kk = find( strcmp( var.name, {loop.reg.name}));
        if isempty(kk)
            error('addLink:badInput', 'Specified component doesn''t seem to exist')
        end
        var.type = loop.reg(kk).type;
        var.sn = loop.reg(kk).sn;
    elseif strcmp( var.name, 'find') %Type and Sn is assumed to be known
        kk = find( strcmp( var.type, {loop.reg.type}) & var.sn == [loop.reg.sn]);
        if isempty(kk)
            error('addLink:badInput', 'Specified component doesn''t seem to exist')
        end
        var.name = loop.reg(kk).name;
    end
    if ~ isa( var.node, 'double')
        var.node = 'next';
    end
    switch jj
        case 1
            argin = var;
        case 2
            argout = var;
    end
end

%% Check that Sink and Source aren't Incorrectly Specified
if strcmp(argin.type, 'sink')
    error('addLink:sink', 'A sink can''t be sepcified as an input')
end
if strcmp(argout.type, 'source')
    error('addLink:source', 'A source can''t be specified as an output')
end




%% 
%%%------------------------------------------------------------------------
%%% Real Work
%%%------------------------------------------------------------------------


%% Find Next Free Node if Required
for jj = 1:2
    switch jj
        case 1
            var = argin;
        case 2
            var = argout;
    end
    if ( strcmp( var.type, 'node') && strcmp( var.node, 'next') ) % Is it a node with 'next' specified
        switch jj
            case 1
                kk = find( [loop.(var.type)(var.sn).outNum] == 0, 1, 'first');
            case 2
                kk = find( [loop.(var.type)(var.sn).inNum] == 0, 1, 'first');
        end
        if isempty(kk)
            var.node = 1;
            warning('addLink:noFreeNode', 'No free port, connecting to first');
        else
            var.node = kk;
        end
    end
    switch jj
        case 1
            argin = var;
        case 2
            argout = var;
    end
end

%% Print a warning if the connections will overwrite others

if ~ supressWarn
    if strcmp(argin.type, 'node')
        if ~(loop.(argin.type)(argin.sn).outNum(argin.node) == 0)
            warning('addLink:overwrite','Overwriting prior connection in input object')
        end
    else
        if ~(loop.(argin.type)(argin.sn).outNum == 0)
            warning('addLink:overwrite','Overwriting prior connection in input object')
        end
    end

    if strcmp(argout.type, 'node')
        if ~(loop.(argout.type)(argout.sn).inNum(argout.node) == 0)
            warning('addLink:overwrite','Overwriting prior connection in output object')
        end
    else
        if ~(loop.(argout.type)(argout.sn).inNum == 0)
            warning('addLink:overwrite','Overwriting prior connection in output object')
        end
    end
end
        



%% Write the output object into the input object's fields

if strcmp(argin.type, 'node') % check if input is a node
    loop.(argin.type)(argin.sn).outName{argin.node} = argout.name;
    loop.(argin.type)(argin.sn).outType{argin.node} = argout.type;
    loop.(argin.type)(argin.sn).outNum(argin.node) = argout.sn;
else
    loop.(argin.type)(argin.sn).outName = argout.name;
    loop.(argin.type)(argin.sn).outType = argout.type;
    loop.(argin.type)(argin.sn).outNum = argout.sn;
end

%% Write the input object to the output object's fields

if strcmp(argout.type, 'node') % Check if output is a node
    loop.(argout.type)(argout.sn).inName{argout.node} = argin.name;
    loop.(argout.type)(argout.sn).inType{argout.node} = argin.type;
    loop.(argout.type)(argout.sn).inNum(argout.node) = argin.sn;
else
    loop.(argout.type)(argout.sn).inName = argin.name;
    loop.(argout.type)(argout.sn).inType = argin.type;
    loop.(argout.type)(argout.sn).inNum = argin.sn;
end









end






































    
    
