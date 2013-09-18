% ArbLoop Method: Level 4
%
% Get node information from an arbLoop object.  Either the name or serial
% number may be sepcified.  This can be useful to check the internal
% definition of a node, or to understand which objects are connected to
% which port of a node.  

function obj = getNode(loop, arg)

if isa(arg, 'char')
    num = find( strcmp( {loop.node.name}, arg));
    if isempty(num)
        error('getBlock:badArg', 'Unrecognizable Name')
    end    
elseif isa(arg, 'double')
    num = find( [loop.node.sn] == arg);
    if isempty(num)
        error('getBlock:badArg', 'Unrecognizable SN')
    end
else
    error('getBlock:badArg', 'Unidentifiable argument type')
end

obj = loop.node(num);

end


    
    