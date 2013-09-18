% ArbLoop Method: Level 1
% 
% Add a node to an ArbLoop object. A node has an arbitrary number of inputs
% and outputs.  Multiple inputs are summed together and fed directly to the
% multiple outputs.  
% 
% 
% The fields of a node are
% -------- These are added with addNode i.e. this function ----------------
% name - the name of the node (string)
% sn - the serial number of the node (double or int)
% Nin - the number of inputs which get summed (double or int)
% Nout - the number of outputs (double or int)
% ------------- These are added with addLink ------------------------------
% inName - the name of the object connected to the input (char array)
% inType - the type of object connected to the input (char array)
% inNum - the sn of the object connected to the input (double column vector)
% outName - the name of the object connected to the output (char array)
% outType - the type of object connected to the output (char array)
% outNum - the sn of the object connected to the output (double column vector)
% 
% Syntax: [loop, sn] = addNode( loop, name, Nin, Nout)
% 
% Example:
% Add a node named 'Node 1' with 4 inputs and 1 output
% loop = addNode( loop, 'Node 1', 4, 1)

function [loop, sn] = addNode( loop, name, Nin, Nout)

sn = loop.Nnode + 1;
loop.Nnode = sn;

if (Nin < 1) || (Nout < 1)
    error('addNode:moreConex', 'Not enough inputs or outputs')
end

inNum = zeros( Nin, 1);
inName = cell( Nin, 1);
for jj = 1:Nin
    inName{jj, 1} = 'null';
end
inType = inName;

outNum = zeros( Nout, 1);
outName = cell( Nout, 1);
for jj = 1:Nout
    outName{jj,1} = 'null';
end
outType = outName;

loop.node(sn, 1).sn = sn;
loop.node(sn, 1).name = name;
loop.node(sn, 1).Nin = Nin;
loop.node(sn, 1).Nout = Nout;
loop.node(sn, 1).inName = inName;
loop.node(sn, 1).inType = inType;
loop.node(sn, 1).inNum = inNum;
loop.node(sn, 1).outName = outName;
loop.node(sn, 1).outType = outType;
loop.node(sn, 1).outNum = outNum;

% Update Registry
n = loop.Nreg + 1;
loop.Nreg = n;

loop.reg(n).name = name;
loop.reg(n).sn = sn;
loop.reg(n).type = 'node';

end
