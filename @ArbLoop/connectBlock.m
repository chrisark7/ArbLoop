% ArbLoop Method: Level 1
% 
% This function is a wrapper for the addBlock method which simultaneously
% adds a new block and connects it to the final two arguments.  All
% arguments between name, and the final two arguments are passed to
% addBlock and should be specified accordingly.  
%    If one of the connections is an empty array, empty cell array, or an 
% empty string, then that connection is left open.  
%
% Input Arguments
% loop: the ArbLoop model
% name: the name of the new block
% varargin: everything between name and the two connection specifiers is
%       passed directly to addBlock.
% bckCon: back side connection specifier which will be passed to addLink. %
%       Empty specifiers ({}, [], '') will leave that port unconnected.
% frwCon: forward connection. Same specifications as bckCon.
%
% Output Arguments
% loop: the modified ArbLoop model.
% sn: the serial number of the new block.
%
% Examples:
% loop = connectBlock( loop, 'New Block', z, p, k, ...
%                      'Front Block', 'Back Block');
% [loop, sn] = connectBlock( loop, 'Controller', ss, ...
%                      'Plant Out', 'Plant In');
% loop = connectBlock( loop, 'Controller', zpk( z, p, k), ...
%                      'Plant Out', []);
% loop = connectBlock( loop, 'Now Block', tf(a,b), ...
%                      '', 'BackBlock');
% loop = connectBlock( loop, 'New Block', z, p, k, ...
%                      {'block', 4}, {'node', 2, 3});
%
% Usage: [loop, sn] = connectBlock( loop, name, addBlockArgs, ...
%                                   bckCon, frwCon);

function [loop, sn] = connectBlock(loop, name, varargin)

%% Parse varargin
% Connections are the last two arguments.
cons = varargin((nargin-3):(nargin-2));

% Everything in between will be passed to addBlock
bkArgs = varargin(1:(nargin-4));

% Check which connections are empty
bkCon = 1;
frCon = 1;
if strcmp( cons{1}, '') || isempty( cons{1})
    bkCon = 0;
end
if strcmp( cons{2}, '') || isempty( cons{2})
    frCon = 0;
end

%% Add Block and Write Connections

% Add the Block
[loop, sn] = addBlock( loop, name, bkArgs{:});

% Add the Connections
if bkCon
    loop = addLink( loop, cons{1}, name);
end
if frCon
    loop = addLink( loop, name, cons{2});
end
















