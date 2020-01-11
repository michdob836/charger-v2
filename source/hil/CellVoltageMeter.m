if ~isempty(instrfind())
    fclose(instrfind());
end

global s;
s = serial(seriallist, 'BaudRate',  19200, 'Timeout', 1, 'Terminator', 'LF');
fopen(s);

fwrite(s, 'I');
fwrite(s, 0);

while 1
    fwrite(s, 'H');
    H = str2double(fscanf(s));
    fwrite(s, 'L');
    L = str2double(fscanf(s));
    Vh = Adc2Volts(H);
    Vl = Adc2Volts(L);
    Vcell = Adc2Volts(H-L);
    
    fprintf('H: %f\tL: %f\t Cellv1: %f\tCellv2: %f\n', ...
             Vh,    Vl ,    Vcell,      GetCellVoltage() );
    
    pause(0.5);
end

fwrite(s, 'I');
fwrite(s, 0);

fclose(s);
delete(s);
clear s;

