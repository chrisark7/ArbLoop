% ArbLoop Method: Level 2
% 
%   This function runs through the loop structure and returns a list of all
% of the nodes which are acting as summers.  It is intended to be used as
% part of the getTF call to generate the equation matrix for row reduction.
% 
% Output:
% ndlist: a cell array of two part arrays of the summing nodes in the form
%    {{'node', sn1}, {'node', sn2}, ...}
%
% Example: ndlist = genSplitNodes( loop);

function ndlist = genSplitNodes( loop)

lnt = length( loop.node);
ndlist = cell(1);
ndCnt = 0;
for jj = 1:lnt
    if loop.node(jj).Nin > 1
        ndCnt = ndCnt + 1;
        ndlist{ndCnt} = {'node', loop.node(jj).sn};
    end
end