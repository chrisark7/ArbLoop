% ArbLoop Method: Level 1
%
%    This function like the other connect functions adds a source and
% simultaneously connects it.  
%
% Example:
% [loop, sn] = connectSource( loop, 'New Source', 'Input of Interest')
%
% Usage:
% [loop, sn] = connectSource( loop, name, con)

function [loop, sn] = connectSource( loop, name, con)

[loop, sn] = addSource( loop, name);

loop = addLink( loop, name, con);