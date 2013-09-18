% ArbLoop Method: Level 1
% 
% This function is a wrapper script for the addBlock method.  It adds a
% block with the given name which has the zpk structure ([], [], k) with
% the gain specified by k
%

function [loop, sn] = addGain( loop, name, k)

[loop, sn] = addBlock(loop, name, [], [], k);

end