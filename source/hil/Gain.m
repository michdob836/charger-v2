function kvar = Gain(ma)
a =      0.1504;
b =    0.000778;
c =    -0.05154;
kvar = a*exp(b*ma) + c;
end

