function [u,R,g] = dynamicSynapse(g_bar,tau_syn,U0, tau_d,tau_f,pre_spike_train,dt)
%Short-term Synaptic Plasticity 
%      Args:
%    g_bar           : synaptic conductance strength
%    tau_syn         : synaptic time constant [ms]
%    U0              : synaptic release probability at rest
%    tau_d           : synaptic depression time constant of x [ms]
%    tau_f           : synaptic facilitation time constantr of u [ms]
%    pre_spike_train : total spike train (number) input
%                      from presynaptic neuron
%    dt              : time step [ms]
%    Returns:
%    u               : usage of releasable neurotransmitter
%    R               : fraction of synaptic neurotransmitter resources available
%    g               : postsynaptic conductance
    Lt = length(pre_spike_train);
    u = zeros(1,Lt);
    R = zeros(1,Lt);
    R(1) = 1;
    g = zeros(1,Lt);
    
    for it = 1:(Lt-1)
        %compute du
        du = -(dt/tau_f)*u(it) + U0*(1.0 - u(it))*pre_spike_train(it+1);
        u(it + 1) = u(it) + du;
        %compute dR
        dR = (dt/tau_d)*(1.0 - R(it)) - u(it+1)*R(it)*pre_spike_train(it + 1);
        R(it+1) = R(it) + dR;
        %compute dg
        dg = -(dt/tau_syn)*g(it) + g_bar*R(it)*u(it+1)*pre_spike_train(it + 1);
        g(it + 1) = g(it) + dg;
    end
    
end

