% ArbLoop Support Function: Level 2
% 
% 


function writeToTxt(arg, filename)

out = arg;


if exist(filename, 'file') > 0
    delete( filename);
end

% Understand the lengths
Nmap = length(out);
cellLnts = zeros([Nmap 1]);
stringLnt = 0;
for jj = 1:Nmap
    nowMap = out(jj);
    nowLnt = length(nowMap.name);
    cellLnts(jj) = nowLnt;
    for kk = 1:nowLnt
        stringLnt = max( stringLnt, length(nowMap.name{kk}));
    end
end

fid = fopen(filename, 'w');
for jj = 1:max(cellLnts);
    nowStr = '';
    for kk = 1:Nmap
        if jj <= cellLnts(kk)
            nowLnt = length(out(kk).name{jj});
            nowSpc = stringLnt - nowLnt + 1;
            nowStr2 = out(kk).name{jj};
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

fclose(fid);