function [FlyKeyStatus fitness_i] = compute_ga(i1,i2,w1,w2,Bird,jump_tic)
% i1 = Tubes.ScreenX(next_tube);
% i2 = dely;
o1 = [i1 i2]*w1*w2;
 o1a = 1/(1+exp(-o1));

fitness_i = Bird.ScrollX - i1;
FlyKeyStatus = 0;
if o1a > 0.5
    jump_toc = toc;
    if jump_toc - jump_tic > 0.12 %min time in seconds between jumps.  equals to 7.5 Hz, which is max I could press the button.
        FlyKeyStatus = 1;
        jump_tic = toc;
    end
end
end