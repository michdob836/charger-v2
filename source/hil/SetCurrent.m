function SetCurrent(miliamps)
    global s;
    regVal = DacReg(miliamps);
    fwrite(s, 'I');
    fwrite(s, regVal);
end

