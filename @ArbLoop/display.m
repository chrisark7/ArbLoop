% ArbLoop Method: Level 2
% 
% This function displays information about the ArbLoop model and is called
% automatically by Matlab when the name of an ArbLoop object is called
% without a semicolon.

function display( loop)

% Maximum width to display in workspace
maxLnt = 80;

% Initial Display
disp('This ArbLoop model contains the following objects:')

% Blocks
disp('BLOCKS')
for jj = 1:loop.Nblock
    % Create string with serial number, name, backward connection, and
    % forward connection.
    nowDisp = [sprintf('%1.0d', jj) ') ' loop.block(jj).name ...
        '  (<-) {' loop.block(jj).inName '}  (->) {' ...
        loop.block(jj).outName '}'];
    % If the string is longer than maxLnt we need to display it as a number
    % of seperate lines.
    if length(nowDisp)/maxLnt > 1
        nowExt = length(nowDisp) - maxLnt;
        nowLnt = ceil( nowExt/(maxLnt - 4)) + 1;
        nowNum = 1;
        for kk = 1:nowLnt
            if kk == 1
                disp(nowDisp(1:maxLnt))
                nowNum = nowNum + maxLnt;
            elseif kk == nowLnt
                disp(['    ' nowDisp(nowNum:end)])
            else
                disp(['    ' nowDisp(nowNum:(nowNum + maxLnt - 4))])
                nowNum = nowNum + maxLnt - 4;
            end
        end
    else
        disp(nowDisp)
    end
end

disp('SINKS')
for jj = 1:loop.Nsink
    nowDisp = [sprintf('%1.0d', jj) ') ' loop.sink(jj).name ...
        '  (<-) {' loop.sink(jj).inName '}'];
    if length(nowDisp)/maxLnt > 1
        nowExt = length(nowDisp) - maxLnt;
        nowLnt = ceil( nowExt/(maxLnt - 4)) + 1;
        nowNum = 1;
        for kk = 1:nowLnt
            if kk == 1
                disp(nowDisp(1:maxLnt))
                nowNum = nowNum + maxLnt;
            elseif kk == nowLnt
                disp(['    ' nowDisp(nowNum:end)])
            else
                disp(['    ' nowDisp(nowNum:(nowNum + maxLnt - 4))])
                nowNum = nowNum + maxLnt - 4;
            end
        end
    else
        disp(nowDisp)
    end
end

disp('SOURCES')
for jj = 1:loop.Nsource
    nowDisp = [sprintf('%1.0d', jj) ') ' loop.source(jj).name ...
        '  (->) {' loop.source(jj).outName '}'];
    if length(nowDisp)/maxLnt > 1
        nowExt = length(nowDisp) - maxLnt;
        nowLnt = ceil( nowExt/(maxLnt - 4)) + 1;
        nowNum = 1;
        for kk = 1:nowLnt
            if kk == 1
                disp(nowDisp(1:maxLnt))
                nowNum = nowNum + maxLnt;
            elseif kk == nowLnt
                disp(['    ' nowDisp(nowNum:end)])
            else
                disp(['    ' nowDisp(nowNum:(nowNum + maxLnt - 4))])
                nowNum = nowNum + maxLnt - 4;
            end
        end
    else
        disp(nowDisp)
    end
end

disp('NODES')
for jj = 1:loop.Nnode
    nowDisp = [sprintf('%1.0d', jj) ') ' loop.node(jj).name ...
        '  (<-) {'];
    nowLnt = length(loop.node(jj).inName);
    for kk = 1:nowLnt
        if kk == nowLnt
            nowDisp = [nowDisp loop.node(jj).inName{kk} '}  (->) {'];
        else
            nowDisp = [nowDisp loop.node(jj).inName{kk} ', '];
        end
    end
    nowLnt = length(loop.node(jj).outName);
    for kk = 1:nowLnt
        if kk == nowLnt
            nowDisp = [nowDisp loop.node(jj).outName{kk} '}'];
        else
            nowDisp = [nowDisp loop.node(jj).outName{kk} ', '];
        end
    end
    if length(nowDisp)/maxLnt > 1
        nowExt = length(nowDisp) - maxLnt;
        nowLnt = ceil( nowExt/(maxLnt - 4)) + 1;
        nowNum = 1;
        for kk = 1:nowLnt
            if kk == 1
                disp(nowDisp(1:maxLnt))
                nowNum = nowNum + maxLnt;
            elseif kk == nowLnt
                disp(['    ' nowDisp(nowNum:end)])
            else
                disp(['    ' nowDisp(nowNum:(nowNum + maxLnt - 4))])
                nowNum = nowNum + maxLnt - 4;
            end
        end
    else
        disp(nowDisp)
    end
end







