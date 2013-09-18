%
% mf = filtProd(mf0, mf1, ...)
%
% return the product of argument filters
%

function mf = filtProd(varargin)

  z = [];
  p = [];
  k = 1;
  for jj = 1:length(varargin)
    nowFilt = varargin{jj};
    z = [z; nowFilt.z];
    p = [p; nowFilt.p];
    k = k * nowFilt.k;
  end

  mf.z = z;
  mf.p = p;
  mf.k = k;
