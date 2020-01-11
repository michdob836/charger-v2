function AbortCharging()
    global s;
    SetCurrent(0);
    fwrite(s, 'R');
    fwrite(s, 1);
    fprintf('... aborted.\n');
end