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
timestep = 0.001; % s
h = 0.1; % s

FileName=['./log/ident_',datestr(now,'yymmdd_HH-MM-SS'),'.tsv'];
log = fopen(FileName,'w');
fprintf(log,'Is\t t_Is\t Ir\t t_Ir\t Vc\t t_Vc\n');

Is = [];
Ir = [];
Vc = [];
U = 0;
vl = 0;

tic
time = toc;
lastSet = toc;
try
    while toc < howLongWillItTake
       
        if toc - lastSet > Tu
            if Vc(1, end) > absMaxV
                %bump down max voltage for rand
                uMax = 0.9 * uMax;
                if uMax < uMin
                    fprintf('Finished: uMax < uMin\n');
                    break;
                end
            end
            U = rand() * (uMax - uMin) + uMin;
            lastSet = toc;
        end

        Is(:,end+1) = [0 0];
        Ir(:,end+1) = [0 0];
        Vc(:,end+1) = [0 0];
          
        while (  toc < time + h)
            % wait until its time for next sample
            pause(timestep);
        end
        
        Is(:,end) = [U toc];
        time = toc;
        fwrite(s, 'K');
        fwrite(s, DacReg(U));
        vcell = str2double(fscanf(s));
        vcell = 7.433e-05 * vcell*4 + 0.0894;
        
%         vl = GetCellLowSide();
%         Ir(:,end) = [vl/Rs toc];
        
%         vh = GetCellHighSide();
         Vc(:,end) = [vcell toc];

        fprintf(log, '%f\t%f\t%f\t%f\t%f\t%f\n', ...
                Is(1, end), Is(2, end), Ir(1, end), Ir(2, end), ...
                Vc(1, end), Vc(2, end) );
            
        fprintf('%f\t%f\t%f\t%f\t%f\t%f\n', ...
                Is(1, end), Is(2, end), Ir(1, end), Ir(2, end), ...
                Vc(1, end), Vc(2, end) );
        
    end
catch
    AbortCharging();
end
SetCurrent(0);
fclose(s);
delete(s);
clear s;
fclose(log);
fprintf('Cleanup done. Exiting.\n');
end