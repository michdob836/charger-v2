function [measured, diff] = SetCurrent(miliamps)
    global s;
    Rs = 0.08;
    regVal = DacReg(miliamps);
    fwrite(s, 'I');
    fwrite(s, regVal);

    fwrite(s, 'L');
    L = str2double(fscanf(s));
    Vl = 7.508e-05 * L + 0.0022;
    measured = Vl / Rs * 1000;
    diff = measured - miliamps;
end

