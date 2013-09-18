% ArbLoop Method: Level 1
% 
% Add a sink to an ArbLoop object.  Transfer functions will be calculated
% from all sources to all sinks.  A sink is therfore ArbLoops way of
% knowing that the user wants to know the transfer function to this point 
% from a source.  
% 
% A sink has the following fields:
% -------- These are added with addSink i.e. this function ----------------
% name - the name of the sink (string)
% sn - the serial number of the sink (double or int)
% ------------- These are added with addLink ------------------------------
% inName - the name of the object connected to the input (string)
% inType - the type of object connected to the input (string)
% inNum - the sn of the object connected to the input (double or int)
% 
% Usage:
% [loop, sn] = addSink( loop, name)
%

function [loop, sn] = addSink(loop, name)

sn = loop.Nsink + 1;
loop.Nsink = sn;

loop.sink(sn, 1).sn = sn;
loop.sink(sn, 1).name = name;

loop.sink(sn, 1).inName = 'null';
loop.sink(sn, 1).inType = 'null';
loop.sink(sn, 1).inNum = 0;


% Update Registry
n = loop.Nreg + 1;
loop.Nreg = n;

loop.reg(n).name = name;
loop.reg(n).sn = sn;
loop.reg(n).type = 'sink';

end