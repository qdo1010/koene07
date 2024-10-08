%ADD STP AND STD and see what's going on....
%HOW TO ADD THAT?
clear;
%koene 2007
%t = linspace(0,500,1000);
%tau_rise = 10^-4;
%tau_fall = 30;
%G = 23;
%E_rev = -90;

%t_max = (tau_rise*tau_fall*log(tau_rise/tau_fall))/(tau_rise - tau_fall);
%%%wrong%%%t_max = log((tau_fall/tau_rise)/(((1/tau_rise)-(1/tau_fall))));
%a_norm = 1/(exp(-t_max/tau_fall) - exp(-t_max/tau_rise));
%g = G*a_norm*(exp(-t/tau_fall) - exp(-t/tau_rise));

%figure()
%plot(t_max)
%plot(t,g)

c.AHP = 1;
currents(c.AHP).tau_rise = 1e-4;
currents(c.AHP).tau_fall = 30;
currents(c.AHP).G = 23/2550;
currents(c.AHP).Erev = -90;
currents(c.AHP).anorm = findanorm(currents(c.AHP));

c.ADP = 2;
currents(c.ADP).tau_rise = (135 + 1e-4);
currents(c.ADP).tau_fall = 135;
currents(c.ADP).G = 30/2550;
currents(c.ADP).Erev = -35;
currents(c.ADP).anorm = findanorm(currents(c.ADP));

c.theta = 3;
currents(c.theta).tau_rise = 0.1;
currents(c.theta).tau_fall = 8;%20/10;
currents(c.theta).G = 10;
currents(c.theta).Erev = -70;
currents(c.theta).anorm = findanorm(currents(c.theta));

c.spike = 4;
currents(c.spike).tau_rise = 1;
currents(c.spike).tau_fall = 2;
currents(c.spike).G = 32;
currents(c.spike).Erev = 0;
currents(c.spike).anorm = findanorm(currents(c.spike));

c.gamma = 5;
currents(c.gamma).tau_rise = 0.1/10;
currents(c.gamma).tau_fall = 2.5/10;
currents(c.gamma).G = 150;
currents(c.gamma).Erev = -70;
currents(c.gamma).anorm = findanorm(currents(c.gamma));

leak_current.tau_fall = 9;
leak_current.G = 111;
leak_current.Erev = -60;



%input to Gamma
c2.AHP = 1;
currents2(c2.AHP).tau_rise = 1e-4;
currents2(c2.AHP).tau_fall = 30;
currents2(c2.AHP).G = 23;
currents2(c2.AHP).Erev = -70;
currents2(c2.AHP).anorm = findanorm(currents2(c2.AHP));

c2.PyrInput = 2;
currents2(c2.PyrInput).tau_rise = 1;
currents2(c2.PyrInput).tau_fall = 2;
currents2(c2.PyrInput).G = 32;
currents2(c2.PyrInput).Erev = 0;
currents2(c2.PyrInput).anorm = findanorm(currents2(c2.PyrInput));

leak_current2.tau_fall = 10;
leak_current2.G = 100;
leak_current2.Erev = -70;


num_P = 3;
for i = 1:num_P
    neurons(i).V = [];
    neurons(i).V(1) = -60; %V_0
    neurons(i).spike_time = [];
    neurons(i).V_th = -58;%0;%-38; %change to change subthresholds spiking
    neurons(3).V_th = -58; %change to change subthresholds spiking
    neurons(2).V_th = -58; %change to change subthresholds spiking

    neurons(i).V_reset = -75;
end

gammaNeuron.V = [];
gammaNeuron.V(1) = -70;
gammaNeuron.spike_time = [];
gammaNeuron.V_th = -38;
gammaNeuron.V_reset = -75;

T = 10000;
SpikeHistory = zeros(num_P,T); %P x S
GSpikeHistory = zeros(1,T); %P x S

V_hist = zeros(num_P,T); % P x S
V_gamma_hist = zeros(1,T); % P x S

t_spike = zeros(num_P,1);
t_theta = 0;
t_Gspike = 0;
for t = 1:T
    if (mod(t-1,125) == 0) %theta rhythm
        t_theta = t-1; 
    end
    
    %elseif t > 1500 && t < 2000
    %    currents(c.ADP).G = 30/3000;
    %    currents(c.ADP).anorm = findanorm(currents(c.ADP));
    %elseif t > 2000
    %    currents(c.ADP).G = 30/2700;
    %    currents(c.ADP).anorm = findanorm(currents(c.ADP));
    %end
    for p = 1:num_P
        %if t > 1000 && p==2 && t<2000%modulation maybe? This change order of stuff
        %    currents(c.ADP).G = 30/1000;
        %    currents(c.ADP).anorm = findanorm(currents(c.ADP));
        %else
        %    currents(c.ADP).G = 30/2550;
        %    currents(c.ADP).anorm = findanorm(currents(c.ADP));
        %end
        %V_hist(p,1) = neurons(p).V(1);
        [neurons(p).V(t+1), spike] = updatePyramid(p,t,t_spike,t_Gspike,t_theta,currents,leak_current,SpikeHistory,GSpikeHistory,neurons);
        %we can add specificity to the gamma neuron, but not now!

        if spike == 1
            SpikeHistory(p,t) = 1;
            t_spike(p) = t;
            %make gamma spike as well
            GSpikeHistory(1,t) = 1;
            t_Gspike = t;
        end
        [gammaNeuron.V(t+1), Gspike] = updateGamma(t,t_Gspike,currents2,leak_current2,GSpikeHistory,gammaNeuron);
        V_gamma_hist(1,t) = gammaNeuron.V(t);
        V_hist(p,t) = neurons(p).V(t);
       
    end

end

%for i =1:num_P
plot(V_hist(1,:))
hold on;
plot(V_hist(2,:)-20)
hold on;
plot(V_hist(3,:)-30)
hold on;
%end
plot(V_gamma_hist(1,:)-400)
xlabel("ms")
ylabel("mv")
%xlim([2000 4000])