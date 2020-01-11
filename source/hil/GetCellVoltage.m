function Vcell = GetCellVoltage()
    global s;
    fwrite(s, 'H');
    H = str2double(fscanf(s));
    Vh = 7.437e-5 * H + 0.0957;
    fwrite(s, 'L');
    L = str2double(fscanf(s));
    Vl = 7.508e-05 * L + 0.0022;
    Vcell = Vh - Vl;
end

