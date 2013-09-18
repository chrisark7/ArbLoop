% ArbLoop Method: Level 4
% 
%
% This function will take an ArbLoop object and generates the maps from
% its outputs to either an input or a loop closure.  This is useful for
% checking that the ArbLoop object is properly connected.  It is often
% more useful to call the function writeMapToTxt instead which will write
% the map to a more easily readable text file.  
%

function maps = genMap(loop)


Nsink = loop.Nsink;
maps.Nmap = 0;
for jj = 1:Nsink
    arg = {'sink', loop.sink(jj).sn};
    sinkMap = genMapFromSink(loop, arg);
    %Write to loop structure
    for kk = 1:sinkMap.Nmap
        maps.Nmap = maps.Nmap + 1;
        maps.map(maps.Nmap).name = sinkMap.map(kk).name;
        maps.map(maps.Nmap).type = sinkMap.map(kk).type;
        maps.map(maps.Nmap).sn = sinkMap.map(kk).sn;
    end
end


end
















