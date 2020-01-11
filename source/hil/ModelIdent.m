function stats = ModelIdent(Amplit, Offset, howLong)
if ~isempty(instrfind())
    fclose(instrfind());
end

global s;
s = serial('/dev/ttyUSB0', 'BaudRate',  9600, 'Timeout', 1, 'Terminator', 'LF');
fopen(s);

SetCurrent(0);
fwrite(s, 'R');
fwrite(s, 0);
fwrite(s, 'G');
fwrite(s, 0);

absMaxV = 4.2;
absMinV = 2.5;

h = 0.25; 
stats = [];
figure(1);
hold on;
k = 1000;
Ti = 2;

try
Vcell = GetCellVoltage();
fprintf('Cell voltage: %1.2fV... ', Vcell);
if (absMinV <= Vcell) && (Vcell < absMaxV)
    fprintf('ok.\n');
    fprintf('Ready to sine it to death. Proceed? ');
    pause();
    fprintf('\n');
    fwrite(s, 'G');
    fwrite(s, 1);
    tic
    Vcell = GetCellVoltage();
    while (absMinV <= Vcell) && (Vcell < absMaxV) 
        pause(h);
        if(toc > howLong)
            break;
        end
        CV = Amplit*(sin(2*pi*0.1* toc)+1)/2+Offset;
        [measured, diff] = SetCurrent(CV);
        Vcell = GetCellVoltage();
        
        fprintf('Voltage: %1.2fV\t SetCurr: %4.0fmA\t MeasuredCurr: %4.0fmA\t Diff: %4.0fmA\n', ...
                    Vcell, CV, measured, diff);
        stats(:,end+1) = [Vcell CV measured toc];
        
        cla;
        subplot(1, 2, 1)
        plot(stats(1,:), 'k');
        subplot(1, 2, 2)
        hold on;
        plot(stats(2,:), 'r');
        plot(stats(3,:), 'b');
    end
end
catch
    AbortCharging();

end
AbortCharging();
fclose(s);
delete(s);
clear s;
end