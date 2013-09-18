% ArbLoop Method: Level 1
%
%    This function inserts a link between an object and an already
% connected loop.  It does so by first inserting a node prior to the object
% and the connection point so the the original connection remains intact.
% It is therfore distinct from the addLink function in that it will not
% overwrite a connection.  The specification for the connection points is
% however the same as for the addLink function.
%    If an object is not yet connected, then insertLink will not add a node
% before connecting.  Essentially, insertLink will check to see if the
% objects are connected, and if they are it will add a node if front of or
% begind (depending on context) and connect that node to the other object.
% It can therefore also be used to add a short circuit between two points
% if both points are already connected although the other path will not be
% broken.  
%
% Usage: loop = insertLink( loop, in, out)

function loop = insertLink( loop, in, out)

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

%% Check to See which Objects are Already Connected.

bckCon = loop.(argin.type)(argin.sn);
fwdCon = loop.(argout.type)(argout.sn);

% Initialize flags to tell if the connections were previously unconnected.
bckFlag = 0; %1=previously connected; 0=previously unconnected
fwdFlag = 0;
if strcmp( argin.type, 'node')
    % If it is a node things of course have to be handled differently.
    % If the port specification of the node is next, check to see if any of
    % the ports are null and choose the first null one if so.  If not
    % choose the first one.
    if strcmp( argin.node, 'next')
        nowOut = find( strcmp( bckCon.outType, 'null'));
        if isempty( nowOut)
            argin.node = 1;
            bckFlag = 1;
        else
            argin.node = nowOut(1);
        end
    % If the port is specified we simply need to check whether the port is
    % already used or not and set the flag appropriately.  
    else
        if ~strcmp(bckCon.outType{argin.node}, 'null')
            bckFlag = 1;
        end
    end
    % Finally, we need to define the connection point for use when making
    % later connections.
    bckSpec = {argin.type, argin.sn, argin.node};
    % If the backwards connection was previously connected, then we need to
    % get then information about the object to which it was previously
    % connected.  If it was a node, then things are slightly more
    % complicated.
    if bckFlag
        bckPrior.type = bckCon.outType{argin.node};
        bckPrior.sn = bckCon.outNum(argin.node);
        if strcmp( bckPrior.type, 'node')
            nowCon = loop.node(bckPrior.sn);
            nowOut = find( strcmp( nowCon.inType, argin.type) & ...
                nowCon.inNum == argin.sn);
            bckPrior.node = nowOut;
            bckPriorSpec = {bckPrior.type, bckPrior.sn, bckPrior.node};
        else
            bckPriorSpec = {bckPrior.type, bckPrior.sn};
        end
    end
% If the specified connection is not a node we simply need to check if the
% port is already taken or not.
else
    if ~strcmp(bckCon.outType, 'null')
        bckFlag = 1;
    end
    % Define the connection point
    bckSpec = {argin.type, argin.sn};
    % If the connection was previously connected, then we  need to
    % understand what it was connected to.  
    if bckFlag
        bckPrior.type = bckCon.outType;
        bckPrior.sn = bckCon.outNum;
        if strcmp( bckPrior.type, 'node')
            nowCon = loop.node(bckPrior.sn);
            nowOut = find( strcmp( nowCon.inType, argin.type) & ...
                nowCon.inNum == argin.sn);
            bckPrior.node = nowOut;
            bckPriorSpec = {bckPrior.type, bckPrior.sn, bckPrior.node};
        else
            bckPriorSpec = {bckPrior.type, bckPrior.sn};
        end
    end
end

%Repeat for the forward connection.
if strcmp( argout.type, 'node')
    if strcmp( argout.node, 'next')
        nowOut = find( strcmp( fwdCon.inType, 'null'));
        if isempty( nowOut)
            argout.node = 1;
            fwdFlag = 1;
        else
            argout.node = nowOut(1);
        end
    else
        if ~strcmp( fwdCon.inType{argout.node}, 'null')
            fwdFlag = 1;
        end
    end
    fwdSpec = {argout.type, argout.sn, argout.node};
    if fwdFlag
        fwdPrior.type = fwdCon.inType{argout.node};
        fwdPrior.sn = fwdCon.inNum(argout.node);
        if strcmp( fwdPrior.type, 'node')
            nowCon = loop.node(fwdPrior.sn);
            nowOut = find( strcmp( nowCon.outType, argout.type) & ...
                nowCon.outNum == argout.sn);
            fwdPrior.node = nowOut;
            fwdPriorSpec = {fwdPrior.type, fwdPrior.sn, fwdPrior.node};
        else
            fwdPriorSpec = {fwdPrior.type, fwdPrior.sn};
        end
    end
else
    if ~strcmp( fwdCon.inType, 'null')
        fwdFlag = 1;
    end
    fwdSpec = {argout.type, argout.sn};
    if fwdFlag
        fwdPrior.type = fwdCon.inType;
        fwdPrior.sn = fwdCon.inNum;
        if strcmp( fwdPrior.type, 'node')
            nowCon = loop.node(fwdPrior.sn);
            nowOut = find( strcmp( nowCon.outType, argout.type) & ...
                nowCon.outNum == argout.sn);
            fwdPrior.node = nowOut;
            fwdPriorSpec = {fwdPrior.type, fwdPrior.sn, fwdPrior.node};
        else
            fwdPriorSpec = {fwdPrior.type, fwdPrior.sn};
        end
    end
end



%% Add Nodes for the Objects which were Already Connected

if bckFlag
    % We need to choose a name for the node which doesn't already exist in
    % the registry
    bckName = [argin.name ' Link Nd'];
    nowNum = 0;
    while sum( strcmp( {loop.reg.name}, bckName)) > 0
        nowNum = nowNum + 1;
        bckName = [argin.name ' Link Nd ' sprintf('%1.0d', nowNum)];
    end
    % Create the node with one input and two outputs
    [loop, nowSn] = addNode( loop, bckName, 1, 2);
    % Link the node input to bckSpec and one of the outputs to bckPriorSpec
    % supressing the warnings since we will be overwriting connections.
    loop = addLink( loop, bckSpec, bckName, 'supressWarn', 1);
    loop = addLink( loop, bckName, bckPriorSpec, 'supressWarn', 1);
    %Overwrite bckSpec for the final connections below.
    bckSpec = {'node', nowSn};
end

if fwdFlag
    fwdName = [argout.name ' Link Nd'];
    nowNum = 0;
    while sum( strcmp( {loop.reg.name}, fwdName)) > 0
        nowNum = nowNum + 1;
        fwdName = [argout.name ' Link Nd ' sprintf('%1.0d', nowNum)];
    end
    [loop, nowSn] = addNode( loop, fwdName, 2, 1);
    loop = addLink( loop, fwdPriorSpec, fwdName, 'supressWarn', 1);
    loop = addLink( loop, fwdName, fwdSpec, 'supressWarn', 1);
    fwdSpec = {'node', nowSn};
end

%% Create Final Connection

loop = addLink( loop, bckSpec, fwdSpec);

    
        
        
    





















