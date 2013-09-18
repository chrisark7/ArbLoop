% ArbLoop Method: Level 2
% 
%   This function generates the maps between a number of 'in' points and a 
% single 'out' point.  It is used in the getTF call to generate the system 
% of equations betwen the sink/nodes and the sum points which are then 
% solved with row reduction techniques.  
%   It is important to be careful when using this call because an 
% improperly specified set of 'in' points can result in an infinite loop.
% The algorithm has a built in exit strategy for this case which will
% return the results after 100 iterations and generate a warning.
% 
% Inputs:
% loop: The ArbLoop variable contianing the model.
% in: An array of cell arrays contianing the points to which the maps 
%   will be generated.  Example: {{'source', 1}, {'node', 2}, {'node', 8}}
% out: A cell array containing the point from which the propogation will
%   start.  Example: {'sink', 102}.  This is a singular point.
% 
% Output:
% maps: A structure of length = length(in) containing the maps between 
%   the in points and the out point.  Example: maps(1).map.name will 
%   contian the names of the blocks between in{1} and out.  If the map is 
%   empty between one of the in points and out, then the maps entry will 
%   contian maps(j).map.name = 'null', maps(j).map.type = 'null', and
%   maps(j).map.sn = 0.  If there are multiple maps between a given in and
%   out the will be given by maps(j).map(k) where k runs over the number of
%   maps between the two points.  
% 
% Usage:
% maps = genMapFromTo( loop, in, out)
% 

function maps = genMapFromTo( loop, in, out)

%% Some Error Checking and Initilization
lnt = length( in);

% in can't be a sink
for jj = 1:lnt
    if strcmp( in{jj}{1}, 'sink')
        error('genMapFromTo:badFrom', ...
            'in points can not be sinks')
    end
end

% out can't be a source
if strcmp( out{1}, 'source')
    error('genMapFromTo:badTo', ...
        'out point can not be a source')
end

sinkType = out{1};
sinkSn = out{2};

%% Initialize the Internal Structures
% Internal maps
map.name{1} = loop.(sinkType)(sinkSn).name;
map.type{1} = sinkType;
map.sn(1) = loop.(sinkType)(sinkSn).sn;

% Initialize stopping structure
intl.stop.flag = 1;
nLoop = 1;

% Re structure in for easier checking
checkType = cell( lnt, 1);
checkSn = zeros( lnt, 1);
for jj = 1:lnt
    checkType{jj} = in{jj}{1};
    checkSn(jj) = in{jj}{2};
end

%% Generate Maps 
while sum( [intl.stop.flag]) > 0
    nLoop = nLoop + 1;
    nMap = length([intl.stop.flag]);
    for jjc = 1:nMap
        nMap = length([intl.stop.flag]);
        switch intl.stop(jjc).flag
            case 0
                continue
            case 1
                % Get Previous Object Info
                type1 = map(jjc).type{nLoop -1};
                sn1 = map(jjc).sn(nLoop -1);
                % If this object is a node, copy the current map to
                % loop.node.sn.inNum number of map structures, then
                % append each input node to a different map.
                if strcmp( type1, 'node')
                    % Store the indices of the original and the new
                    % maps
                    intl.num = loop.node(sn1).Nin - 1;
                    intl.ind = [jjc ((1:intl.num) + nMap)];
                    if ~(intl.num == 0)
                        % Create the map copies and new stop bits
                        for kkc = 2:length(intl.ind)
                            map(intl.ind(kkc)).name = map(jjc).name;
                            map(intl.ind(kkc)).type = map(jjc).type;
                            map(intl.ind(kkc)).sn = map(jjc).sn;
                            % Create new stop bit
                            intl.stop(intl.ind(kkc)).flag = 1;
                        end
                    end
                    % Store the new object information in each map
                    for kkc = 1:length(intl.ind)
                        name2 = loop.node(sn1).inName{kkc};
                        type2 = loop.node(sn1).inType{kkc};
                        sn2 = loop.node(sn1).inNum(kkc);
                        map(intl.ind(kkc)).name{nLoop} = name2;
                        map(intl.ind(kkc)).type{nLoop} = type2;
                        map(intl.ind(kkc)).sn(nLoop) = sn2;
                        % Check if the map has hit one of the in points
                        if 0 < sum( (sn2 == checkSn) & strcmp( type2, checkType))
                            intl.stop(intl.ind(kkc)).flag = 0;
                        % If the map hits a source we also need to stop
                        elseif strcmp( type2, 'source')
                            intl.stop(intl.ind(kkc)).flag = 0;
                        end
                    end
                else
                    name2 = loop.(type1)(sn1).inName;
                    type2 = loop.(type1)(sn1).inType;
                    sn2 = loop.(type1)(sn1).inNum;
                    map(jjc).name{nLoop} = name2;
                    map(jjc).type{nLoop} = type2;
                    map(jjc).sn(nLoop) = sn2;
                    % Check if the map has hit one of the in points
                    if 0 < sum( (sn2 == checkSn) & strcmp( type2, checkType))
                        intl.stop(jjc).flag = 0;
                    % If the map hits a source we also need to stop
                    elseif strcmp( type2, 'source')
                        intl.stop(jjc).flag = 0;
                    end
                end
        end
        % A failsafe
        if nLoop > 100
            clear intl.stop.flag
            for kkc = 1:length( intl.stop)
                intl.stop(kkc).flag = 0;
            end
            warning('genMapFromTo:infLoop', ...
                ['The inputs appear to be improperly specified and the '...
                'propogation is stuck in an infinite loop.  ' ...
                'Returning current results, but they are probably incorrect.'])
        end
    end
end
nMap = length( [intl.stop.flag]);

%% Assemble into the Output maps Structure
% Assemble final points of map for easy checking
fnlType = cell( nMap, 1);
fnlSn = zeros( nMap, 1);
for jj = 1:nMap
    fnlType{jj} = map(jj).type{end};
    fnlSn(jj) = map(jj).sn(end);
end

for jj = 1:lnt
    nowType = checkType{jj};
    nowSn = checkSn(jj);
    nowInds = find( strcmp( fnlType, nowType) & ( fnlSn == nowSn));
    if length( nowInds) > 1
        for kk = 1:length(nowInds)
            maps(jj).map(kk) = map( nowInds(kk));
        end
    elseif length( nowInds) == 1
        maps(jj).map = map(nowInds);
    else
        maps(jj).map.name = {'null'};
        maps(jj).map.type = {'null'};
        maps(jj).map.sn = 0;
    end
end

    





























