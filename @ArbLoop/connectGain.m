% ArbLoop Method: Level 1
% 
% This function is a wrapper for the addGain method which simultaneously
% adds a new gain stage described by the arguments name and k while
% connecting it to the argumen connection.
% 
% Note that the connect methods, like the insert methods connect to the 
% input  of the specified connection.  Building a loop with the connect 
% methods should therefore be done from the end working backwards.

function [loop, sn] = connectGain( loop, name, k, connection)

[loop, sn] = addGain(loop, name, k);

loop = addLink( loop, name, connection);
