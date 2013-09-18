% ArbLoop Method: Level 1
% 
% This function uses the addSink and addLink scripts to insert a sink 
% into an already constructed loop.  As with the other insert scripts it 
% inserts the new sink in front of the specified point by default, but an
% optional argument can be passed to have it inserted after.  
% 
% Be careful when using the insert functions around nodes unless the node 
% has only one connection in the necessary direction.  If you must use them
% in front of a node with more than one backward connection, specify the 
% specific node connection that you want to use in the form 
% {'node', sn, port}.  See addLink for more information on specifying a 
% specific port number.  Also getNode( loop, 'Node Name') will be helpful.
% 
% Arguments:
% loop: the ArbLoop model.
% name: the name of the sink to be added.
% loc: the location at which the sink will be added.  This is the name of a
%      block or node.  By default the sink is inserted before the object,
%      but an optional argument can be passed to insert it after.
% 
% Optional Arguments:
% breakAfter: 0 or 1 (default is 0).  Passing a 1 for this argument tells
%      ArbLoop to insert the sink after the object specified by loc.
% 
% Output Arguments:
% loop: the modified ArbLoop model.
% sn: the sn of the inserted sink.
%
% Example:
% Insert a sink called 'Out 5' in front of block 'Block 6'
% loop = insertSource( loop, 'Out 5', 'Block 6')
%
% Insert a sink called 'Output 1' in front of node sn 6 port 3.
% loop = insertSource( loop, 'Output 1', {'node', 6, 3})
% 
% Insert a sink called 'TF Out' behind block 'Controller' and retrive the
% sn of the new sink.
% [loop, sn] = insertSource( loop, 'TF Out', 'Controller', ...
%                            'breakAfter', 1);
% 

function [loop, sn] = insertSink(loop, name, loc, varargin)

%% Parse loc
% Retrieve the information about loc
if ischar(loc)
    kk = find( strcmp( loc, {loop.reg.name}));
    if isempty(kk)
        error('insertSource:badInput', 'The specified component doesn''t seem to exist')
    end
    nowLoc.type = loop.reg(kk).type;
    nowLoc.sn = loop.reg(kk).sn;
else
    nowLoc.type = loc{1};
    nowLoc.sn = loc{2};
end

% Is it a node?
if strcmp(nowLoc.type, 'node') && ~ischar(loc)
    ndFlag = 1;
    if length(loc) > 2;
        ndNum = loc{3};
        noSn = 0;
    else
        noSn = 1;
    end
elseif strcmp( nowLoc.type, 'node')
    ndFlag = 1;
    noSn = 1;
else
    ndFlag = 0;
end

loc = {nowLoc.type, nowLoc.sn};

%Optional arguments
%Defaults
breakAfter = 0;
if nargin > 3
    %Optional Arguments should come in pairs
    if ~(mod( nargin - 3, 2) == 0)
        warning('getOLRG:badOptArg', ...
            ['Unable to understand optional argumants, ' ...
            'continuing with defaults'])
    else
        for jj = 1:(length(varargin)/2)
            if strcmp( varargin{2*jj-1}, 'breakAfter')
                breakAfter = varargin{2*jj};
            else
                warning('getOLRG:badOptArg', ...
                    ['Unable to understand optional argumants, ' ...
                    'continuing with defaults'])
            end
        end
    end
end

%% Create Source and Node

[loop, newSinkSn] = addSink(loop, name);
sn = newSinkSn;

[loop, newNodeSn] = addNode(loop, [name ' Nd'], 1, 2);

%% Get Connection Info
if breakAfter
    bckCon = get(loop, loc);
    if ndFlag
        % As always nodes must be handled differently because their
        % connection specifiers are cell arrays unstead of simple strings.
        if noSn
            % If no connection port is passed for the node, then we simply
            % use the first port.
            fwdType = bckCon.outType{1};
            fwdSn = bckCon.outNum(1);
            fwdCon = loop.(fwdType)(fwdSn);
            bckLoc = {nowLoc.type, nowLoc.sn, 1};
        else
            % This is the proper case where a connection port is passed for
            % the node.
            fwdType = bckCon.outType{ndNum};
            fwdSn = bckCon.outNum(ndNum);
            fwdCon = loop.(fwdType)(fwdSn);
            bckLoc = {nowLoc.type, nowLoc.sn, ndNum};
        end
    else
        % If it is not a node, we simply need to grab the proper
        % information.  
        fwdType = bckCon.outType;
        fwdSn = bckCon.outNum;
        fwdCon = loop.(fwdType)(fwdSn);
        bckLoc = loc;
    end
    % If the forward connection is a node, figure out which port points
    % towards bckCon
    if strcmp( fwdType, 'node')
        nowLnt = length( fwdCon.inName);
        for jj = 1:nowLnt
            bool1 = strcmp( fwdCon.inType{jj}, loc{1});
            bool2 = fwdCon.inNum(jj) == loc{2};
            if bool1 && bool2;
                fwdNdNum = jj;
            end
        end
        fwdLoc = {fwdType, fwdSn, fwdNdNum};
    else
        fwdLoc = {fwdType, fwdSn};
    end      
else
    % In this case we break before loc, and the forward connection is
    % simply loc.  We must figure out what the backward connection is
    % though.
    fwdCon = get(loop, loc);
    if ndFlag
        if noSn
            bckType = fwdCon.inType{1};
            bckSn = fwdCon.inNum(1);
            bckCon = loop.(bckType)(bckSn);
            fwdLoc = {nowLoc.type, nowLoc.sn, 1};
        else
            bckType = fwdCon.inType{ndNum};
            bckSn = fwdCon.inNum(ndNum);
            bckCon = loop.(bckType)(bckSn);
            fwdLoc = {nowLoc.type, nowLoc.sn, ndNum};
        end
    else
        bckType = fwdCon.inType;
        bckSn = fwdCon.inNum;
        bckCon = loop.(bckType)(bckSn);
        fwdLoc = loc;
    end
    % If backward connection is a node, figure out which port points towards
    % fwdCon
    if strcmp(bckType, 'node')
        nowLnt = length( bckCon.outName);
        for jj = 1:nowLnt
            bool1 = strcmp( bckCon.outType{jj}, loc{1});
            bool2 = bckCon.outNum(jj) == loc{2};
            if bool1 && bool2
                bckNdNum = jj;
            end
        end
        bckLoc = {bckType, bckSn, bckNdNum};
    else
        bckLoc = {bckType, bckSn};
    end
end

%% Add Links

% Link new output and new node
loop = addLink( loop, {'node', newNodeSn}, {'sink', newSinkSn}, ...
    'supressWarn', 1);

% Link backward object and new node
loop = addLink( loop, bckLoc, {'node', newNodeSn}, ...
    'supressWarn', 1);

% Link new node to forward object
loop = addLink( loop, {'node', newNodeSn}, fwdLoc, ...
    'supressWarn', 1);





























