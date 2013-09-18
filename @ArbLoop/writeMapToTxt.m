% ArbLoop Method: Level 4
% 
%    This function writes the map to the text file specified in the 
% function call.  It can be a useful way of checking that all connections 
% are properly made. If a third argment is passed, the txt file will 
% include the nodes, otherwise it will not.
%    The map starts from every sink and propogates backwards until it
% either hits a source of closes on itself.  It is therefor a
% representation of every unique way of a signal getting to each sink.
% This is useful for diagnosing incorrectly conected ArbLoop Models.
%
% Usage: writeMapToTxt( loop, filename, varargin); 
% 
% Example:
% writeMapToTxt( loop, 'Maps.txt');           (without nodes)
% writeMapToTxt( loop, 'MapsWNodes.txt', 1);  (with nodes)
% 

function writeMapToTxt(loop, filename, varargin)

%% Get map with genMap
maps = genMap( loop);

%% Remove Nodes if requested
if nargin > 3
    rmvNode = 0;
else
    rmvNode = 1;
end

if rmvNode
    for jj = 1:maps.Nmap
        nowMap = maps.map(jj);
        nowLn = length(nowMap.name);
        clear nowMap2
        Nent = 0;
        for kk = 1:nowLn
            if ~strcmp( nowMap.type{kk}, 'node')
                Nent = Nent + 1;
                nowMap2.name{Nent} = nowMap.name{kk};
                nowMap2.type{Nent} = nowMap.type{kk};
                nowMap2.sn(Nent) = nowMap.sn(kk);
            end
        end
        maps.map(jj) = nowMap2;
    end
end

%% Write to the Specified Txt File
    
% Delete old file
if exist(filename, 'file') > 0
    delete( filename);
end

% Understand the lengths
Nmap = maps.Nmap;
cellLnts = zeros([Nmap 1]);
stringLnt = 0;
for jj = 1:Nmap
    nowMap = maps.map(jj);
    nowLnt = length(nowMap.name);
    cellLnts(jj) = nowLnt;
    for kk = 1:nowLnt
        stringLnt = max( stringLnt, length(nowMap.name{kk}));
    end
end

% Write to File
fid = fopen(filename, 'w');
for jj = 1:max(cellLnts);
    nowStr = '';
    for kk = 1:Nmap
        if jj <= cellLnts(kk)
            nowLnt = length(maps.map(kk).name{jj});
            nowSpc = stringLnt - nowLnt + 1;
            nowStr2 = maps.map(kk).name{jj};
            for ll = 1:nowSpc
                nowStr2 = [nowStr2 ' '];
            end
        else
            nowStr2 = '';
            for ll = 1:(stringLnt + 1)
                nowStr2 = [nowStr2 ' '];
            end
        end
        nowStr = [nowStr nowStr2];
    end
    nowStr;
    fprintf(fid, '%s\r\n', nowStr);
end

% Close the file session
fclose(fid);

