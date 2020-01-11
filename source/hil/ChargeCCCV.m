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

absMaxV = 4.2;
absMinV = 2.5;
threshRegulatorOn = 0.1; %V
h = 0.15; % okres próbkowania, s

stats = [];
figure(1);
hold on;

k = 4000;
Ti = 6;

try
Vcell = GetCellVoltage();
fprintf('Cell voltage: %1.2fV... ', Vcell);
if (absMinV <= Vcell) && (Vcell < absMaxV)
    fprintf('ok.\n');
    chargingCurrent = cellCapacity * chargingRate;
    Icell = chargingCurrent; % initial output for pi controller
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
    regon = 0;
    while (absMinV <= Vcell) && (Vcell < absMaxV) 
        pause(h);

        if Vcell > targetV - threshRegulatorOn
            %CV stage
            e = targetV - Vcell;
            i = i + h/Ti * e;
            Icell =  Gain(Icell) * k * ( e + i );
            regon = 1;
        else
            %CC stage
            Icell  = chargingCurrent;
            i = Icell/(Gain(Icell) *k);
            regon =0;
        end
        if Icell > chargingCurrent
            %regulator wypracował za wysoki prąd: limituj i ustaw całkę
            Icell = chargingCurrent;
            i = Icell/(Gain(Icell) *k);
            regon = 3;
        end
        if Icell < cutoffC
            fprintf('\nCharged!\n');
            break;
        end
        [measured, diff] = SetCurrent(Icell);
    
        Vcell = GetCellVoltage();
        fprintf('Voltage: %1.2fV\t SetCurr: %4.0fmA\t MeasuredCurr: %4.0fmA\t Diff: %4.0fmA CV?:%1d\n', ...
                    Vcell, Icell, measured, diff, regon);
        fprintf(fileID, '%1.2f\t%4.0f\t%4.0f\t%1d\t%5.2f\n', ...
                    Vcell, Icell, measured, regon, toc);
        stats(:,end+1) = [Vcell Icell measured toc];
        cla;
        subplot(1, 2, 1)
        plot(stats(1,:), 'k');
        subplot(1, 2, 2)
        hold on;
        plot(stats(2,:), 'r');
        plot(stats(3,:), 'b');
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