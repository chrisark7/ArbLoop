% ArbLoop Class Initiator
%
% Class fields are:
%
% block - a cell array of transfer function blocks.
% Nblock - number of blocks
% node - an object which sums its inputs and branches its outputs.
% Nnode - number of input points
% source - a 'from' point for a transfer function
% Nsource - number of sources
% sink - a 'to' point for a transfer function
% Nsink - number of sinks
% reg - a registry of the items in ArbLoop
% Nreg - the number of registry entries
%
% 
% Methods are denoted as levels 1-4
% Level 1: The root interactions with ArbLoop.  Used to build the ArbLoop 
%    model.  Intended to be used by the user and other ArbLoop Methods.
% Level 2: Generally intended to be submethods of other higher level
%    methods, i.e. not typically intedended for the user.
% Level 3: High level methods used to extract information once the loop 
%    model is built, and intended primarily for use by the user.  These 
%    methods perform actions such as extracting a transfer function.
% Level 4: High level methods used to check that the ArbLoop model is 
%    properly connected, and intended for use by the user.  These methods
%    perform actions such as error checking and printing maps to the
%    screen.  These methods will generally not be used once an ArbLoop
%    model is fully functional.  
% 

function loop = ArbLoop(varargin)

    newBlock = struct('sn', 0, 'name', 'null',...
                   'z', [], 'p', [], 'k', 1,...
                   'inName', 'null', 'inType', 'null', 'inNum', 0,...
                   'outName', 'null', 'outType', 'null', 'outNum', 0, ...
                   'isNum', 0, 'f', [], 'resp', []);

    newSource = struct('sn', 0, 'name', 'null',...
                   'outName', 'null', 'outType', 'null', 'outNum', 0);

    newSink = struct('sn', 0, 'name', 'null',...
                   'inName', 'null', 'inType', 'null', 'inNum', 0);

    newNode = struct('sn', 0, 'name', 'null',...
                   'Nin', 0, 'Nout', 0,...
                   'inName', {'null'}, 'inType', {'null'}, 'inNum', [0],...
                   'outName', {'null'}, 'outType', {'null'}, 'outNum', [0]);
               
    newReg = struct('name', 'null', 'type', 'null', 'sn', 0);
    
    loop = struct('block', newBlock,...
                 'Nblock', 0,...
                 'node', newNode,...
                 'Nnode', 0,...
                 'source', newSource,...
                 'Nsource', 0,...
                 'sink', newSink,...
                 'Nsink', 0,...
                 'reg', newReg,...
                 'Nreg', 0);

    loop = class(loop, 'ArbLoop');
    
    errstr = 'Don''t know what to do with ';	% for argument error messages
    switch( nargin )
        case 0					% default constructor
            
        case 1
            arg = varargin{1};

            % copy constructor
            if( isa(arg, class(loop)) )
                loop = arg;
            else
                error([errstr 'an argument of type %s.'], class(arg));
            end
        otherwise					% wrong number of input args
            error([errstr '%d input arguments.'], nargin);
    end
end
               
