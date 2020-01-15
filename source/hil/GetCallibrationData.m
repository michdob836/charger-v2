if ~isempty(instrfind())
    fclose(instrfind());
end

global s;
s = serial('/dev/ttyUSB0', 'BaudRate',  19200, 'Timeout', 1, 'Terminator', 'LF');
fopen(s);

fwrite(s, 'I');
fwrite(s, 0);

side = 'H'; % 'H' or 'L'

current = 50;
di = 100; %mA

voltData = [];

notMeltingYet = 1;
fprintf(['Input current voltage at ' side ' cell teminal or -1 for abort.\n']);

while notMeltingYet
    fprintf('Iset = %4.0f, Vdmm = ', current);
    V_dmm = input('');
    
    if V_dmm < 0
        notMeltingYet = 0;
        fwrite(s, 'I');
        fwrite(s, 0);
        break;
    end
    
    fwrite(s, side);
    adcReg = str2double(fscanf(s));
    voltData(:,end+1) = [adcReg ; V_dmm]; 
   
    fprintf([side ': %f\t'], adcReg/64);
    fprintf('\tIm = %f\n', V_dmm /1000 / 0.08);
    
    current = current + di;
    fwrite(s, 'I');
    fwrite(s, DacReg(current));
end

fwrite(s, 'I');
fwrite(s, 0);

fclose(s);
delete(s);
clear s;

