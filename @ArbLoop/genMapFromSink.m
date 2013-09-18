% ArbLoop Method: Level 2
% 
% This function generates the map from a specified sink and passes it back.
% It is intended mainly as a sub-routine of the genMap function.

function mapFromSink = genMapFromSink(loop, out)

    % Parse the Input
    if ischar(out)
        kk = find( strcmp( out, {loop.reg.name}));
        if isempty(kk)
            error('getTF:badInput', 'The specified component doesn''t seem to exist')
        end
        sinkType = loop.reg(kk).type;
        sinkSn = loop.reg(kk).sn;
    else
        sinkType = out{1};
        sinkSn = out{2};
    end

    % Initialize map structure
    map.name{1} = loop.(sinkType)(sinkSn).name;
    map.type{1} = sinkType;
    map.sn(1) = loop.(sinkType)(sinkSn).sn;

    %Initialize internal structure
    intl.stop.flag = 1;
    nLoop = 1;

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
                            % Check for loop closure or a source
                            closeCheck = sum( strcmp(name2, map(intl.ind(kkc)).name)) > 1;
                            if strcmp( type2, 'source')
                                intl.stop(intl.ind(kkc)).flag = 0;
                            elseif closeCheck
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
                        % Check for loop closure or a source
                        closeCheck = sum( strcmp( name2, map(jjc).name)) > 1;
                        if strcmp( type2, 'source')
                            intl.stop(jjc).flag = 0;
                        elseif closeCheck
                            intl.stop(jjc).flag = 0;
                        end
                    end
            end
            % A failsafe
            if nLoop > 500
                intl.stop.flag = 0;
            end
        end
    end
    nMap = length( [intl.stop.flag]);
    mapFromSink.map = map;
    mapFromSink.Nmap = nMap;
end