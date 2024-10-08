function [V,spike] = updateGamma(t,t_spike,currents,leak_current,SpikeHistory,neurons)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    C = 1;
    %v = -60;
    dt = 1;
    %neurons(p).V(t) = neurons(p).V_reset;
    I_pyr = 100;
    numerator = 0;
    denominator = 0;
    if (t <= (t_spike + 400))  && (t > (t_spike))  && t_spike>0
        for i = 1:length(currents)
            g_i = currents(i).G*currents(i).anorm*(exp(-(t-t_spike)/currents(i).tau_fall) - exp(-(t-t_spike)/currents(i).tau_rise));
            numerator = numerator + g_i*dt*(currents(i).Erev - neurons.V(t));
            denominator = denominator + g_i*dt;
        end
    %end
    
    end
    dv = numerator/(C + denominator) + (dt/leak_current.tau_fall)*(leak_current.Erev-neurons.V(t)) +(dt/leak_current.tau_fall)*(I_pyr/leak_current.G); 

    if (t > 1) && (SpikeHistory(1,t-1) == 1)
        neurons.V(t) = 0;
        spike = 0;
        dv = 0;
    elseif (t > 2) && (SpikeHistory(1,t-2) == 1)
        neurons.V(t) = neurons.V_reset;
        spike = 0;   
        dv = 0;
    elseif (t > 3) && (SpikeHistory(1,t-3) == 1)
        neurons.V(t) = neurons.V_reset;
        spike = 0; 
        dv = 0;
    elseif neurons.V(t) >= neurons.V_th
        spike = 1;
        neurons.V(t) = 0;
        dv = 0;
    else
        spike = 0;
    end
    V = neurons.V(t) + dv;
end

