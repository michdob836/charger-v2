%% Import Setup
opts = delimitedTextImportOptions("NumVariables", 5);
opts.DataLines = [2, Inf];
opts.Delimiter = "\t";
opts.VariableNames = ["Vcell", "Icell", "measured", "regon", "time"];
opts.VariableTypes = ["double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
data = readtable("./log/charging_20200113_18-02-03.tsv", opts);
clear opts

tiledlayout(2,1)

Vmax= 4.2; %V
e_max = 0.015; %V 

axVoltage = nexttile;
hold on;
plot(axVoltage, [0 data.time(end)/60], [Vmax+e_max Vmax+e_max ],'r')
plot(axVoltage, [0 data.time(end)/60], [Vmax Vmax],'g')
plot(axVoltage, [0 data.time(end)/60], [Vmax-e_max Vmax-e_max],'r')
plot(axVoltage, data.time/60, data.Vcell, 'k')
title(axVoltage,'Napięcie na ogniwie')
ylabel(axVoltage,'napięcie, V')
xlabel(axVoltage,'czas, min')
hold off;

axCurrent = nexttile;
plot(axCurrent,data.time/60, data.measured, 'k', data.time/60, data.Icell, 'r' )
title(axCurrent,'Prąd ładowania')
ylabel(axCurrent,'prąd, mA')
xlabel(axCurrent,'czas, min')
legend(axCurrent, 'Dane poglądowe z ADC', 'Wartość wypracowana przez regulator')