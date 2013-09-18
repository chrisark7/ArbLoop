% ArbLoop Method: Level 1
% 
% Add a source to an ArbLoop object.  Transfer functions will be calculated
% from sources to sinks.  A source is therfore ArbLoop's way of
% knowing that the user wants to know the transfer function from this point
% to a sink.  
% 
% A source has the following fields:
% -------- These are added with addSource i.e. this function --------------
% name - the name of the source (string)
% sn - the serial number of the source (double or int)
% ------------- These are added with addLink ------------------------------
% outName - the name of the object connected to the output (string)
% outType - the type of object connected to the output (string)
% outNum - the sn of the object connected to the output (double or int)
% 
% Syntax:
% [loop, sn] = addSource(loop, name)

function [loop, sn] = addSource(loop, name)

sn = loop.Nsource + 1;
loop.Nsource = sn;

loop.source(sn, 1).sn = sn;
loop.source(sn, 1).name = name;

loop.source(sn, 1).outName = 'null';
loop.source(sn, 1).outType = 'null';
loop.source(sn, 1).outNum = 0;


% Update Registry
n = loop.Nreg + 1;
loop.Nreg = n;

loop.reg(n).name = name;
loop.reg(n).sn = sn;
loop.reg(n).type = 'source';

end
























