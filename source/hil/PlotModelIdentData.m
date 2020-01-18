Ir1 = d.Is/1000;
Vc1 = d.Vc;
t_Ir1 = d.t_Is;
t_Vc1 = d.t_Is;

figure(2);
tiledlayout(2,1)
ai = nexttile;
plot(ai,t_Ir1/60, Ir1, 'k');
% axis([0 t_Ir1(end)/60 inf inf]);
av = nexttile;
plot(av, t_Vc1/60, Vc1, 'k');
% axis([0 t_Vc1(end)/60 inf inf]);