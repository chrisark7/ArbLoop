% ArbLoop Method: Level 2
% 
% This function retrieves the z, p, and k entry from a block object and
% returns them in an mf filter structure.  Taken from the mf directory
% in the lentickle folder.  The input name can be in either of the usual
% forms.
% 

function mf = getBlockZPK( loop, name)

if ischar(name)
    kk = find( strcmp( name, {loop.reg.name}));
    if isempty(kk)
        error('filtProd:badInput', 'One of the specified components doesn''t seem to exist')
    end
    fltBlck{1} = loop.reg(kk).type;
    fltBlck{2} = loop.reg(kk).sn;
else
    fltBlck{1} = name{1};
    fltBlck{2} = name{2};
end

if ~strcmp(fltBlck{1}, 'block')
    error('filtZPK:badInput', 'The specified component should be a block')
end 

mf.z = loop.(fltBlck{1})(fltBlck{2}).z;
mf.p = loop.(fltBlck{1})(fltBlck{2}).p;
mf.k = loop.(fltBlck{1})(fltBlck{2}).k;



