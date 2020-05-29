clear
close all
clc
delete(gcf)
%Simplified, only generates random gap vertical position and wind speed

%run gerate tube sprite first
plotting = true;
limiter = ([0 1e4]);
tube_no = 1e7;% number of tubes to generate
wind_no =  1e6;

tube_mat_z =ceil(rand(1,tube_no)*105);
wind_lim = [1.0 2.0];
% base_wind = mean(wind_lim)
base_wind = 1.5;
wind_mat = ones(1,wind_no)*base_wind;

toggle = 1;
walk_speed = 4;

grav_mat = ones(1,wind_no)*0.1356;
grav_lim = [0.1356*0.5 0.1356*1.5]

for i = 2:wind_no/toggle %total matrix size   
%     wind_mat(i*toggle-toggle+1:i*toggle) = wind_mat((i-1)*toggle-toggle+1:(i-1)*toggle) -0.05+round(rand(1)/10,2);
    wind_mat(i*toggle-toggle+1:i*toggle) = wind_mat((i-1)*toggle-toggle+1:(i-1)*toggle) -0.05*walk_speed+round(rand(1)/10*walk_speed,2);
    
    if wind_mat(i*toggle-toggle+1) > wind_lim(2)
        wind_mat(i*toggle-toggle+1:i*toggle) = wind_lim(2);
    elseif wind_mat(i*toggle-toggle+1) < wind_lim(1)
        wind_mat(i*toggle-toggle+1:i*toggle) = wind_lim(1);
    end
    
grav_mat(i*toggle-toggle+1:i*toggle) = grav_mat((i-1)*toggle-toggle+1:(i-1)*toggle) -0.005*4+rand(1)*4/100;

    
if grav_mat(i*toggle-toggle+1) > grav_lim(2)
        grav_mat(i*toggle-toggle+1:i*toggle) = grav_lim(2);
    elseif grav_mat(i*toggle-toggle+1) < grav_lim(1)
        grav_mat(i*toggle-toggle+1:i*toggle) = grav_lim(1);
    end
    
end


%Stress testing
% tube_mat_y(11:2000) = y_spread; %To check the hardest possible combination
% tube_mat_z = ones(1,tube_no)*1;
% tube_mat_z(2:2:end) = 105;
save('Tube_Data_v8.mat','tube_mat_z','tube_no','wind_no','wind_mat','grav_mat')
%Optional Plotting
%Absolute Data
if plotting

%     subplot(2,1,1)
%     plot(tube_mat_z,'r')
%     xlabel('Tube Number')
%     ylabel('Gap Position (arb.)')
%     title('Gap Position')
%     xlim(limiter)
    subplot(2,1,1)
    plot(wind_mat,'r')
    xlabel('Cumulative Score/2')
    ylabel('Wind Speed X(arb)')
%     title('Gap Position (Relative)')
%     ylim([0 1.2])
xlim(limiter)
 subplot(2,1,2)
    plot(0.1356-grav_mat,'r')
    xlabel('Cumulative Score/2')
    ylabel('Wind Speed Y (arb)')
%     title('Gap Position (Relative)')
%     ylim([0 1.2])
xlim(limiter)
end
