function reg_val = DacReg(miliamps)
%DACREG Summary of this function goes here
%   Detailed explanation goes here
Rs = 0.08;
Udac = 10/(10+100) * 2.5;
reg_val =  uint8(miliamps / 1000.0 * Rs * 256.0/Udac);

end

