% ArbLoop Method: Level 4
%
% Returns the registry of the ArbLoop object.  If the function is called
% without any output arguments, then the registry is printed to the
% workspace in a readable format.  

function varargout = getRegistry(loop)

if nargout ==1
    varargout = loop.reg;
else
    display([ {loop.reg.name}' {loop.reg.type}' {loop.reg.sn}'])
end

end

