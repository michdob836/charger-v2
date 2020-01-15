function Vh = GetCellLowSide()
    global s;
    fwrite(s, 'H');
    H = str2double(fscanf(s));
    Vh = 7.433e-05 * H + 0.0894;
end

