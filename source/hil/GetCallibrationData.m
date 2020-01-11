fclose(instrfind)
s = serial('COM3', 'BaudRate',  9600, 'Timeout', 1, 'Terminator', 'LF');
fopen(s);

fwrite(s, 'I');
fwrite(s, 0);

current = 0;
di = 50; %mA

voltData = [];

notMeltingYet = 1;
fprintf('Input current voltage at high cell teminal or -1 for abort.\n');

while notMeltingYet 
    V_dmm = input('V_dmm, mV: ');
    if V_dmm < 0
        notMeltingYet = 0;
        fwrite(s, 'I');
        fwrite(s, 0);
        break;
    end
    
    fwrite(s, 'L');
    L = str2double(fscanf(s));
    fprintf('    L: %f       ', L/64);
    
    voltData(:,end+1) = [L V_dmm/1000]; 
    
    fprintf('Iset = %f\t Ireal = %f\n', current / 1000, V_dmm /1000 / 0.08);
    
    fwrite(s, 'I');
    fwrite(s, DacReg(current));
    current = current + di;

    
end

fwrite(s, 'I');
fwrite(s, 0);

fclose(s);
delete(s);
clear s;

