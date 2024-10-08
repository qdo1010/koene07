function [V,spike] = updatePyramid(p,t,t_spike,t_Gspike, t_theta,currents,leak_current,SpikeHistory,GammaSpikeHistory,neurons)
%calculate the membrane potential at each time step t for neuron p
%   Detailed explanation goes here
% g(i) is actually a response function!!, NOT A differential equation!!
% THIS ASSUME A SPIKE OCCURS at g(i) at t= 0 and at later time point!!
% ONLY CALCULATE g(i) when a current/spike is added!!

    C = 1;
    %v = -60;
    dt = 1;
        %neurons(p).V(t) = neurons(p).V_reset;
    if (mod(t-1,125) == 0) %theta rhythm
        i =3;
        I_theta = -50;
        numerator = 0;
        denominator = 0;
        g_i = currents(i).G*currents(i).anorm*(exp(-(t - t_theta)/currents(i).tau_fall) - exp(-(t-t_theta)/currents(i).tau_rise));
        numerator = numerator + g_i*dt*(currents(i).Erev - neurons(p).V(t));
        denominator = denominator + g_i*dt; 
    %end
    elseif (t == 100 && p ==1)  || (t == 225 && p ==2) || (t == 355 && p ==3) %input to current
        I_theta = 3000;
        numerator = 0;
        denominator = 0;
        for i = 1:length(currents)-1 %1,2,3,4
            if i ~= 3
            g_i = currents(i).G*currents(i).anorm*(exp(-(0)/currents(i).tau_fall) - exp(-(0)/currents(i).tau_rise));
            numerator = numerator + g_i*dt*(currents(i).Erev - neurons(p).V(t));
            denominator = denominator + g_i*dt;
            end
        end
    %just spike from the same neuron history
    elseif (t <= (t_spike(p) + 400))  && (t >= (t_spike(p)))  && t_spike(p)>0
        I_theta = 0;
        numerator = 0;
        denominator = 0;
        for i = 1:length(currents)-2 %1,2,3
            g_i = currents(i).G*currents(i).anorm*(exp(-(t-t_spike(p))/currents(i).tau_fall) - exp(-(t-t_spike(p))/currents(i).tau_rise));
            numerator = numerator + g_i*dt*(currents(i).Erev - neurons(p).V(t));
            denominator = denominator + g_i*dt;
        end
    %if gamma neuron decide to spike
    elseif (t <= (t_Gspike + 300))  && (t >= (t_Gspike))  && (t_Gspike>0)  
        %gamma
        numerator = 0;
        denominator = 0;
        if (t > 1) && (GammaSpikeHistory(1,t-1) == 1)
            I_theta = -50; %from gamma neuron
        else
            I_theta = 0;
        end
        i = 5;
        g_i = currents(i).G*currents(i).anorm*(exp(-(t-t_Gspike)/currents(i).tau_fall) - exp(-(t-t_Gspike)/currents(i).tau_rise));
        numerator = numerator + g_i*dt*(currents(i).Erev - neurons(p).V(t));
        denominator = denominator + g_i*dt;
        
    else % theta_currnt
        i = 3;
        I_theta = -50;

        numerator = 0;
        denominator = 0;
        g_i = currents(i).G*currents(i).anorm*(exp(-(t - t_theta)/currents(i).tau_fall) - exp(-(t-t_theta)/currents(i).tau_rise));
        numerator = numerator + g_i*dt*(currents(i).Erev - neurons(p).V(t));
        denominator = denominator + g_i*dt; 

    end
    dv = numerator/(C + denominator) + (dt/leak_current.tau_fall)*(leak_current.Erev-neurons(p).V(t)) +(dt/leak_current.tau_fall)*(I_theta/leak_current.G); 
    
    
    if (t > 1) && (SpikeHistory(p,t-1) == 1)
        neurons(p).V(t) = 0;
        spike = 0;
        dv = 0;
    elseif (t > 2) && (SpikeHistory(p,t-2) == 1)
        neurons(p).V(t) = neurons(p).V_reset;
        spike = 0;   
        dv = 0;

    elseif (t > 3) && (SpikeHistory(p,t-3) == 1)
        neurons(p).V(t) = neurons(p).V_reset;
        spike = 0; 
        dv = 0;

    elseif neurons(p).V(t) >= neurons(p).V_th
        spike = 1;
        neurons(p).V(t) = 0; 
        dv = 0;
    else
        spike = 0;
    end
    V = neurons(p).V(t) + dv;
end

