q = 1.60217662 * (10^(-19)); %elementary charge
k = 1.38064852 * (10^(-23));  %Boltzmanns constant
n = 1.4;      %ideality factor
I_SC = 6.15;    % Short circuit current
V_OC = 0.721;     %Open circuit voltage
T = 298.15;       %Cell temperature
V = linspace(0,0.76);    %Using voltage as input variable
T_0 = 298.15;       % Reference temp = 25C
I_r0 = 1000       %reference Irradiance
TC = 0.0029;        % temp coefficint of Isc by manufacturer
V_g = 1.79*(10^(-19));  % Band gap in Joules
I_r = 200
[V_m,I_rm] = meshgrid(V,I_r);    %creating meshgrid
I_s0 = 1.2799*(10^-8);       %Saturation current at ref temp given by equation in  research paper
I_ph = ((I_SC/I_r0).*I_rm).*(1+ TC*(T-T_0));  % Equation for photocurrent, given in paper
I_s = I_s0.*(T./T_0).^(3/n).*exp((-(q*V_g)/n*k).*((1./T)-(1/T_0)));  %saturation current equation in paper
I = I_ph - I_s.*exp(((q*V_m)/(n*k*T))-1);   % Current equation
P = I.*V;
Iplot=I;              
Iplot(Iplot<0)=nan;  
Pplot = P;
Pplot(Pplot<0)=nan;
yyaxis left
plot(V,Iplot);
yyaxis right
plot(V,Pplot);