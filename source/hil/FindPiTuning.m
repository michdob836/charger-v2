ob =  load('model.mat');
ob = ob.tf2;
h= 0.2;
% ob = d2d(ob, h);
delay = tf(1,1,'InputDelay', h);

ob = d2c(ob, 'tustin');

nKp = 100;
nTi = 100;
vKp = logspace(0,1, nKp);
vTi = logspace(-0.6990,0.920, nTi);
res = zeros(100, 3);
it_res = 1;

tic;
for iKp = 1:nKp
    for iTi = 1:nTi
        reg = pidstd(vKp(iKp), vTi(iTi));
%         reg = c2d(reg, h, 'tustin');
        otw = series( reg, ob);
        zamkn = feedback(otw, delay);
        info = stepinfo(zamkn, 'SettlingTimeThreshold',0.1);
        
        if info.Overshoot < 0.1 
            [am, pm] = margin(otw);
            if pm > 60 && mag2db(am) > 10
                res(it_res, :) = [vKp(iKp) vTi(iTi) info.SettlingTime];
                it_res = it_res + 1;
            end
        end
    end
toc
end
toc
res = res(1:it_res-1,:); 
[~, i] = min(res(:,3));
res(i,:)