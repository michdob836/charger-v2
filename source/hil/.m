s = serial('COM3', 'BaudRate', 9600);
fopen(s);
fprintf(s, 'H');
out = fscanf(s);