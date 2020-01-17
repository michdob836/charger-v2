function NyquistizeLTspiceData( pathToRaw )

pathToRaw = '../../spice/Draft1.raw';

d = LTspice2Matlab(pathToRaw);

fr = d.variable_mat(10,:) ./ d.variable_mat(6,:);

plot(fr );
   
end