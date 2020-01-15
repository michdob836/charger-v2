function Vcell = GetCellVoltage()
    global s;
    fwrite(s, 'H');
    H = str2double(fscanf(s));
    Vh = 7.433e-05 * H + 0.0894;
    fwrite(s, 'L');
    L = str2double(fscanf(s));
    Vl = 7.508e-05 * L + 0.007678;
    Vcell = Vh - Vl;
end

