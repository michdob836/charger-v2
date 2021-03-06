function stats = ChargeCCCV(cellCapacity, chargingRate, targetV, cutoffC)
if ~isempty(instrfind())
    fclose(instrfind());
end

global s;
s = serial('/dev/ttyUSB0', 'BaudRate',  19200, 'Timeout', 1, 'Terminator', 'LF');
fopen(s);

SetCurrent(0);
fwrite(s, 'R');
fwrite(s, 0);
fwrite(s, 'G');
fwrite(s, 0);

stats = [];
figure(1);
hold on;

absMaxV = 4.25;
absMinV = 2.5;

h = 0.2; % okres próbkowania, s
k = 3.5112 ;
Ti = 0.2239;
B1 = k*(1+h/(2*Ti));
B2 = k*(h/(2*Ti)-1);

figure(1)
tiledlayout(2,1)
aV = nexttile;
aC = nexttile;

try
Vcell = GetCellVoltage();
fprintf('Cell voltage: %1.2fV... ', Vcell);
if (absMinV <= Vcell) && (Vcell < absMaxV)
    fprintf('ok.\n');
    chargingCurrent = cellCapacity * chargingRate /1000;
    Icell = chargingCurrent;
    fprintf('Ready to charge to %1.2fV at %4.0fmA, %4.0fmA cutoff. Proceed? ',...
            targetV, chargingCurrent, cutoffC);
    pause();
    fprintf('\n');
    fwrite(s, 'G');
    fwrite(s, 1);
    FileName=['./log/charging_',datestr(now,'yyyymmdd_HH-MM-SS'),'.tsv'];
    fileID = fopen(FileName,'w');
    fprintf(fileID,'Vcell\tIcell\tmeasured\tregon\ttime\n');
 
    fwrite(s, 'K');
    fwrite(s, DacReg(0));
    vc = str2double(fscanf(s));
    Vcell  = 7.433e-05 * vc*4 + 0.0894;
   
    Eold = 0;
    tic
    time = toc;
    while (absMinV <= Vcell) && (Vcell < absMaxV) 
        
        while  toc < time + h
            pause(0.005);
        end
        time = toc;

        fwrite(s, 'K');
        fwrite(s, DacReg(Icell*1000));
        vc = str2double(fscanf(s));
        Vcell = 7.433e-05 * vc*4 + 0.0894;
        
        E  = targetV - Vcell;
        Icell = Icell + B1 * E + B2 * Eold;
        Eold = E;
        
         fprintf('Voltage: %1.2f V\t SetCurr: %5.0f mA\t%5.2f\n', ...
                    Vcell, Icell*1000, time);
        
        if Icell > chargingCurrent
            Icell = chargingCurrent;
        end
        if Icell < cutoffC / 1000
            fprintf('\nCharged!\n');
            break;
        end
        
       
        fprintf(fileID, '%1.5f\t%4.2f\t%5.2f\n', ...
                    Vcell, Icell, time);
        stats(:,end+1) = [Vcell Icell time];

        plot(aV,stats(3,:)/60,stats(1,:), 'k');
        plot(aC,stats(3,:)/60,stats(2,:), 'k');
        drawnow;
    end
else
    if Vcell < absMinV
        fprintf('too low.\n');
        AbortCharging();
    else
        fprintf('too high.\n');
        AbortCharging();
    end
end
catch
    fprintf('\nERROR');
    AbortCharging();
end
SetCurrent(0);
fclose(fileID);
fclose(s);
delete(s);
clear s;

end