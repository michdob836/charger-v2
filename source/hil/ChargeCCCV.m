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
Rs = 0.08;

threshRegulatorOn = 0.03; %V
h = 0.25; % okres próbkowania, s
k = 0.1;
Ti = 0.0031;


figure(1)
tiledlayout(2,1)
aV = nexttile;
aC = nexttile;

try
Vcell = GetCellVoltage();
fprintf('Cell voltage: %1.2fV... ', Vcell);
if (absMinV <= Vcell) && (Vcell < absMaxV)
    fprintf('ok.\n');
    chargingCurrent = cellCapacity * chargingRate;
    i=chargingCurrent/1000/k;
    fprintf('Ready to charge to %1.2fV at %4.0fmA, %4.0fmA cutoff. Proceed? ',...
            targetV, chargingCurrent, cutoffC);
    pause();
    fprintf('\n');
    fwrite(s, 'G');
    fwrite(s, 1);
    FileName=['./log/charging_',datestr(now,'yyyymmdd_HH-MM-SS'),'.tsv'];
    fileID = fopen(FileName,'w');
    fprintf(fileID,'Vcell\tIcell\tmeasured\tregon\ttime\n');
    tic
    Vcell = GetCellVoltage();
    time = toc;
    while (absMinV <= Vcell) && (Vcell < absMaxV) 
        while (  toc < time + h)
            pause(0.01);
        end
        time = toc;
        
        e = targetV - Vcell;
        i = i + h/Ti * e;
        Icell =   k * ( e + i ) * 1000;

        if Icell > chargingCurrent
            %regulator wypracował za wysoki prąd: limituj i ustaw całkę
            Icell = chargingCurrent;
            i = i - h/Ti * e;
        end
        if Icell < cutoffC
            fprintf('\nCharged!\n');
            break;
        end
        SetCurrent(Icell);
        
        measured = GetCellLowSide() / Rs * 1000;
        diff = measured - Icell;
    
        Vcell = GetCellVoltage();
        fprintf('Voltage: %1.2fV\t SetCurr: %4.0fmA\t MeasuredCurr: %4.0fmA\t Diff: %4.0fmA\n', ...
                    Vcell, Icell, measured, diff);
        fprintf(fileID, '%1.5f\t%4.2f\t%4.2f\t%5.3f\n', ...
                    Vcell, Icell, measured, toc);
        stats(:,end+1) = [Vcell Icell measured toc];

        plot(aV,stats(4,:)/60,stats(1,:), 'k');
        plot(aC,stats(4,:)/60,stats(2,:), 'r');
        hold on;
        plot(aC, stats(4,:)/60,stats(3,:), 'b');
        hold off;
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
fclose(fileID);
SetCurrent(0);
fclose(s);
delete(s);
clear s;

end