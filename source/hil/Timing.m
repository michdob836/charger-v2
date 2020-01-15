if ~isempty(instrfind())
    fclose(instrfind());
end

global s;
s = serial('/dev/ttyUSB0', 'BaudRate',  19200, 'Timeout', 1, 'Terminator', 'LF');
fopen(s);

tic;
[ GetCellLowSide(); toc; GetCellVoltage; toc]


fclose(s);
delete(s);
clear s;