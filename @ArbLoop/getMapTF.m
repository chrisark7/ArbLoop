% ArbLoop Method: Level 2
% 
%   This method generates the transfer function of a map which is passed to
% it.  The combined response for all of the blocks in the map will be
% output.  Sinks, sources, and nodes will all be assigned a flat transfer
% function of magnitude 1.
% 
% Example:
% resp = getMapTF( loop, map, f);

function resp = getMapTF( loop, map, f)


% Is f a column vector?
nowSz = size(f);
if ~ (nowSz(1) == length(f))
    f = f';
    nowSz = size(f);
end
if ~ (nowSz(2) == 1)
    error('addBlockNumeric:badf', 'f should be a vector')
end

lnt = length( map.type);

totFilt.z = [];
totFilt.p = [];
totFilt.k = 1;
numN = 0;
numFilt.resp = [];
for jj = 1:lnt
    % Get the parameters of the current object
    nowType = map.type{jj};
    nowSn = map.sn(jj);
    % If type is null pass out a vector of zeros
    if strcmp( nowType, 'null')
        resp = zeros( size(f));
        return
    % nodes, sinks, and sources are skipped.
    elseif strcmp( nowType, 'node')
        continue
    elseif strcmp( nowType, 'sink')
        continue
    elseif strcmp( nowType, 'source')
        continue
    elseif strcmp( nowType, 'block')
        % Is it a numeric block
        if loop.block(nowSn).isNum
            numN = numN + 1;
            numFilt(numN).resp = ...
                getNumericBlockTF( loop, {'block', nowSn}, f);
        else
            nowFilt = getBlockZPK( loop, {'block', nowSn});
            totFilt.z = [totFilt.z; nowFilt.z];
            totFilt.p = [totFilt.p; nowFilt.p];
            totFilt.k = totFilt.k * nowFilt.k;
        end
    end
end

%% Calculate Total Transfer Function
resp = intGetZPKtf( totFilt, f);

for jj = 1:numN
    resp = resp .* numFilt(jj).resp;
end


%% Sub Functions
function intResp = intGetZPKtf( intFilt, intf)
    % compute response
    [int.b, int.a] = zp2tf(-intFilt.z, -intFilt.p, intFilt.k);
    intResp = polyval(int.b, 1i * intf) ./ polyval(int.a, 1i * intf);
    
    % check for infinities
    n = find(isinf(intf));
    if( ~isempty(n) )
        if( length(intFilt.p) > length(intFilt.z) )
            intResp(n) = 0;
        elseif( length(intFilt.p) < length(intFilt.z) )
            intResp(n) = intFilt.k * Inf;
        else
            intResp(n) = intFilt.k;
        end
    end
end


end
            
        






















    
    