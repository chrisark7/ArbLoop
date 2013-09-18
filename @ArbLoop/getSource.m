% ArbLoop Method: Level 4
%
% Get source information from an arbLoop object.  Either the name or serial
% number may be sepcified.

function obj = getSource(loop, arg)

if isa(arg, 'char')
    num = find( strcmp( {loop.source.name}, arg));
    if isempty(num)
        error('getBlock:badArg', 'Unrecognizable Name')
    end    
elseif isa(arg, 'double')
    num = find( [loop.source.sn] == arg);
    if isempty(num)
        error('getBlock:badArg', 'Unrecognizable SN')
    end
else
    error('getBlock:badArg', 'Unidentifiable argument type')
end

obj = loop.source(num);

end