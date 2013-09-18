% ArbLoop Method: Level 4
% 
% This function checks the ArbLoop object for missed connections and prints
% information to the workspace.

function checkLoop( loop)

allGood = 1;
for jj = 1:loop.Nsource
    if strcmp( loop.source(jj).outType, 'null');
        nowStr = [ loop.source(jj).name ' is unconnected at its output'];
        disp( nowStr)
        allGood = 0;
    end
end

for jj = 1:loop.Nsink
    if strcmp( loop.sink(jj).inType, 'null');
        nowStr = [ loop.sink(jj).name ' is unconnected at its input'];
        disp(nowStr)
        allGood = 0;        
    end
end

for jj = 1:loop.Nblock
    if strcmp( loop.block(jj).inType, 'null');
        nowStr = [ loop.block(jj).name ' is unconnected at its input'];
        disp( nowStr)
        allGood = 0;
    end
    if strcmp( loop.block(jj).outType, 'null');
        nowStr = [ loop.block(jj).name ' is unconnected at its output'];
        disp( nowStr)
        allGood = 0;
    end
end

for jj = 1:loop.Nnode
    for kk = 1:loop.node(jj).Nin
        if strcmp( loop.node(jj).inType{kk}, 'null')
            nowStr = [ loop.node(jj).name ' is unconnected at input port ' ...
                sprintf( '%d', kk)];
            disp( nowStr)
            allGood = 0;
        end
    end
    for kk = 1:loop.node(jj).Nout
        if strcmp( loop.node(jj).outType{kk}, 'null')
            nowStr = [ loop.node(jj).name ' is unconnected at output port ' ...
                sprintf( '%d', kk)];
            disp( nowStr)
            allGood = 0;
        end
    end
end

if allGood
    disp('All objects are connected')
end




        