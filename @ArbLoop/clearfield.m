% ArbLoop Method: Level 2
%
% Resets a field from the loop structure to the default value

function loop = clearfield(loop, name)

loop2 = ArbLoop();

loop.(name) = loop2.(name);
