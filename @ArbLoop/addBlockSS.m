% ArbLoop Method: Level 1
% 
%    This function takes in a state space model with multiple inputs and
% outputs and adds all of the internal transfer functions to the ArbLoop
% model.  It also creates the necessary nodes and connects them to the
% inputs and outputs.
%    The naming is automatically generated based on the names passed for
% the inputs and ouputs as well as the name of the overall structure.  This
% is best seen in the example below.  Note that it is a very bad idea to
% use identical names for the inputs and outputs.
%    Note also that there is no reason to use this function for a state 
% space model containing only one input and one output which can simply be 
% added with addBlock.
%
% Naming:
% Blocks: [name ': ' inNames{j} ' to ' outNames{k}];
% Nodes:  [name ': ' inNames{j}];
%      or [name ': ' outNames{k}];
%
% Input Arguments:
% loop: the ArbLoop model.
% name: the name of the overall structure.
% ss: the statespace model with N inputs and M outputs
% inNames: a cell array of length N with the names of the inputs.
% outNames: a cell array of length M with the names of the outputs.
%
% Output Arguments:
% loop: the modified ArbLoop model including the full state space model.
% inNd: the names of the input nodes created.
% outNd: the names of the output nodes created.
% 
%- Example:
%- loop = addBlockSS( loop, 'HSTS', hsts, ...
%-                    {'M1 In', 'M3 In'}, ...
%-                    {'M1 Out', 'M3 Out'});
%-   Block Names: 'HSTS: M1 In to M1 Out', HSTS: M3 In to M1 Out', 
%-                'HSTS: M1 In to M3 Out', HSTS: M3 In to M3 Out'
%-   Node Names: 'HSTS: M1 In', 'HSTS: M3 In', 'HSTS: M1 Out', 
%-               'HSTS: M3 Out'
%
% Usage: 
% [loop, inNd, outNd] = addBlockSS( loop, name, ss, inNames, outNames)

function [loop, inNd, outNd] = addBlockSS( loop, name, ss, inNames, outNames)

%% Check the Inputs
sz = size(ss);

% Check that the state space model is larger than 1x1
if ~((sz(1) > 1) || (sz(2) >1))
    erros('addBlockSS:badss', ['The state space model should be ' ...
        'larger than 1x1 to be used with this function.  Use ' ...
        'addBlock instead.'])
end

% Check the length of hte name arrays and the type of variable of name.
if ~(length(inNames) == sz(2))
    error('addBlockSS:badinNames', ['inNames should be a cell array ' ...
        'with ' sprintf('%1.0d', sz(2)) ' entries']);
elseif ~(length(outNames) == sz(1))
    error('addBlockSS:badoutNames', ['outNames should be a cell array '...
        'with ' sprintf('%1.0d', sz(1)) ' entries']);
elseif ~ischar(name)
    error('addBlockSS:badName', 'name should be a string')
end

%% Add Blocks

% Initialize a cell array to store the names of the blocks
blockNames = cell( sz);
for jj = 1:sz(1)
    for kk = 1:sz(2)
        % Add block name to array
        blockNames{jj, kk} = [name ': ' inNames{kk} ' to ' outNames{jj}];
        % Add blocks to the ArbLoop Model
        loop = addBlock( loop, blockNames{jj,kk}, ss(jj,kk));
    end
end

%% Add Nodes

% Initialize name storage arrays
inNodeNames = cell( sz(2), 1);
outNodeNames = cell( sz(1), 1);

% The input nodes
for jj = 1:sz(2)
    % Add name to array
    inNodeNames{jj,1} = [name ': ' inNames{jj}];
    % Add Node with 1 input and sz(1) outputs
    loop = addNode( loop, inNodeNames{jj,1}, 1, sz(1));
end
for jj = 1:sz(1)
    % Add name to array
    outNodeNames{jj,1} = [name ': ' outNames{jj}];
    % Add Node with sz(2) inputs and 1 output
    loop = addNode( loop, outNodeNames{jj,1}, sz(2), 1);
end

%% Add Links

% This will run through each block and connect it first to its input node,
% and then to its output node.
for jj = 1:sz(1)
    for kk = 1:sz(2)
        % Input Node Connection
        loop = addLink( loop, inNodeNames{kk}, blockNames{jj,kk});
        % Output Node Connection
        loop = addLink( loop, blockNames{jj,kk}, outNodeNames{jj});
    end
end

inNd = inNodeNames;
outNd = outNodeNames;
        






























