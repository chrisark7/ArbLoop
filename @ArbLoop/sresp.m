% ArbLoop Method: Level 2
%
%   This script is originally taken from the lentickle mf directory.  It 
% will evaluate an ArbLoop block in the same way that ArbLoop will 
% evaluate it itself.  I.E. it is intended to be used to double check that
% blocks added by the user are correctly specified.  
%   If an output argument is specified it will give the frequency domain 
% response of the filter.  If no output argument is specified it will
% simply generate a plot of the frequency domain response of the filter. If
% no output is specified the extra arguments are passed to the plot
% function.  
%
% Examples:
% resp = sresp( loop, 'Controller', f);
%

function h = sresp(loop, name, f)
   if ischar(name)
       %Search the registry for the identifiers
        kk = find( strcmp( name, {loop.reg.name}));
        if isempty(kk)
            error('sresp:badInput', 'Specified component doesn''t seem to exist')
        end
        bkType = loop.reg(kk).type;
        bkSn = loop.reg(kk).sn;
   else
       bkType = name{1};
       bkSn = name{2};
   end
   
   %Check that specified object is a block
   if ~strcmp( bkType, 'block')
       error('sresp:badInput', 'Specified component should be a block')
   end
   
   mf.z = loop.(bkType)(bkSn).z;
   mf.p = loop.(bkType)(bkSn).p;
   mf.k = loop.(bkType)(bkSn).k;
       

  % compute response
  [b, a] = zp2tf(-mf.z, -mf.p, mf.k);
  h = polyval(b, 1i * f) ./ polyval(a, 1i * f);

  % check for infinities
  n = find(isinf(f));
  if( ~isempty(n) )
    if( length(mf.p) > length(mf.z) )
      h(n) = 0;
    elseif( length(mf.p) < length(mf.z) )
      h(n) = mf.k * Inf;
    else
      h(n) = mf.k;
    end
  end

