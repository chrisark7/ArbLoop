% ArbLoop Method: Level 1 
%
%    This function adds a matrix to an ArbLoop model.  It does so by
% creating the apropriate nodes and blocks since ArbLoop does not
% inherintly know anything about matrices.  
%    It accepts a 2 dimensional matrix.  The 2 dimensional matrix is
% treated as a set of gains which are added as the appropriate blocks.  In 
% order to not create an excess number of connections, zeros are
% parsed as no connection.  
%    The function also takes three naming arguments.  The first argument 
% (name) is the name which will be given to the created blocks along with 
% a pair of numbers denoting the matrix element.  The second two arguments 
% should be cell arrays of lengths size(mat)(2) and size(mat)(1) 
% respcetively.  They will be given to the input and output nodes of the 
% matrix.
%
% Usage: loop = addMatrix( loop, name, mat, inNames, outNames)

function loop = addMatrix( loop, name, mat, inNames, outNames)

%% Check the Inputs
% Size?
sz = size( mat);

% Are inNames and outNames the proper lengths?
if ~(sz(2) == length(inNames))
    error('inNames has an inappropriate length')
end
if ~(sz(1) == length(outNames))
    error('outNames has an inappropriate length')
end


%% Understand the Matrix
% Which elements are zero (2 dim)
noCon = ( mat == 0);

%% Add the Nodes
% Create empty storage for node sn's
inSns = zeros( size( inNames));
outSns = zeros( size( outNames));

% First add the Inputs
for jj = 1:sz(2)
    % We only want to add an input if there is a non-zero element in that
    % column
    if ~( sum( ~noCon(:,jj)) == 0)
        % How many outputs does this input node need to have?
        numCons = sum( ~noCon(:,jj));
        [loop inSns(jj)] = addNode( loop, inNames{jj}, 1, numCons);
    end
end

% Now add the Outputs
for jj = 1:sz(1)
    % We only want to add an output if there is a non-zer element in that
    % row
    if ~( sum( ~noCon(jj,:)) == 0)
        % How many inputs does this output node need to have?
        numCons = sum( ~noCon(jj,:));
        [loop outSns(jj)] = addNode( loop, outNames{jj}, numCons, 1);
    end
end

%% Add the Blocks and Links
% Create empty storage for block sn's
bkSns = zeros( size( mat));

% Run over all matrix elements
for jj = 1:sz(1)
    for kk = 1:sz(2)
        % Only add a block if there isn't a zero here
        if ~noCon(jj,kk)
            % Make the name for this block
            nowName = [name ' ' sprintf('%1.0d', jj) ','...
                sprintf('%1.0d', kk)];
            % Add block
            [loop bkSns(jj,kk)] = addBlock( loop, nowName, [], [], mat(jj,kk));
            % Add backwards link
            loop = addLink( loop, {'node', inSns(kk)}, {'block', bkSns(jj,kk)});
            % Add forwards link
            loop = addLink( loop, {'block', bkSns(jj,kk)}, {'node', outSns(jj)});
        end
    end
end














