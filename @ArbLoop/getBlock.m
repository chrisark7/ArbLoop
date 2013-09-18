% ArbLoop Method: Level 4
%
% Get block information from an arbLoop object.  Either the name or serial
% number may be sepcified.  This can be useful for checking if the block is
% defined properly. 

function obj = getBlock(loop, arg)

if isa(arg, 'char')
    num = find( strcmp( {loop.block.name}, arg));
    if isempty(num)
        error('getBlock:badArg', 'Unrecognizable Name')
    end    
elseif isa(arg, 'double')
    num = find( [loop.block.sn] == arg);
    if isempty(num)
        error('getBlock:badArg', 'Unrecognizable SN')
    end
else
    error('getBlock:badArg', 'Unidentifiable argument type')
end

obj = loop.block(num);

end


    
    