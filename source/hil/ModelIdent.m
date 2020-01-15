function stats = ModelIdent(uMin, uMax, Tu, howLongWillItTake)

if ~isempty(instrfind())
    fclose(instrfind());
end

global s;
s = serial('/dev/ttyUSB0', 'BaudRate',  19200, 'Timeout', 1, 'Terminator', 'LF');
try
    fopen(s);
catch
    fprintf('Cannot open serial.');
    pause;
end

SetCurrent(0);

absMaxV = 4.15;
absMinV = 2.5;
Rs = 0.08;
delay = 0.0001; % s

FileName=['./log/ident_',datestr(now,'yymmdd_HH-MM-SS'),'.tsv'];
log = fopen(FileName,'w');
fprintf(log,'Is\t t_Is\t Ir\t t_Ir\t Vc\t t_Vc\n');

Is = [];
Ir = [];
Vc = [];
U = 0;

tic
lastSet = toc();
try
    while toc < howLongWillItTake
        pause(delay);
        
        if toc - lastSet > Tu
            U = rand() * (uMax - uMin) + uMin;
            lastSet = toc;
        end

        Is(:,end+1) = [0 0];
        Ir(:,end+1) = [0 0];
        Vc(:,end+1) = [0 0];
        
        SetCurrent(U);
        Is(:,end) = [U toc];
        
        vl = GetCellLowSide();
        Ir(:,end) = [vl/Rs toc];
        
        vh = GetCellHighSide();
        Vc(:,end) = [vh-vl toc];

        fprintf(log, '%f\t%f\t%f\t%f\t%f\t%f\n', ...
                Is(1, end), Is(2, end), Ir(1, end), Ir(2, end), ...
                Vc(1, end), Vc(2, end) );
            
        fprintf('%f\t%f\t%f\t%f\t%f\t%f\n', ...
                Is(1, end), Is(2, end), Ir(1, end), Ir(2, end), ...
                Vc(1, end), Vc(2, end) );
        
        if Vc(1, end) > absMaxV
            %bump down max voltage for rand
            uMax = 0.9 * uMax;
            if uMax < uMin
                fprintf('Finished: uMax < uMin\n');
            end
            break;
        end
            
    end
catch
    AbortCharging();
    fclose(log);
end
SetCurrent(0);
fclose(s);
delete(s);
clear s;
fprintf('Cleanup done. Exiting.\n');
end