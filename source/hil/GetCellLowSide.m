function vl = GetCellLowSide()
    global s;
    fwrite(s, 'L');
    L = str2double(fscanf(s));
    vl = 7.508e-05 * L + 0.007678;
end

