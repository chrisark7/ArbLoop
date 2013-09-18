% ArbLoop Method: Level 1
%
%    This function like the other connect functions adds a Sink and
% simultaneously connects it.  
%
% Example:
% [loop, sn] = connectSink( loop, 'New Sink', 'Output of Interest')
%
% Usage:
% [loop, sn] = connectSink( loop, name, con)

function [loop, sn] = connectSink( loop, name, con)

[loop, sn] = addSink( loop, name);

loop = addLink( loop, con, name);