clc;
clear;
close all;

%%====================================================
% Parameters
%%====================================================

Vdc = 565;              % DC Link Voltage
ma  = 0.7;              % Modulation Index
f   = 50;               % Fundamental Frequency (Hz)
Ts  = 10e-6;           % Sampling Time
t_end = 0.04;           % One cycle

t = 0:Ts:t_end;
N = length(t);

%%====================================================
% Reference Voltage Magnitude
%%====================================================

Vref = ma*Vdc/sqrt(3);

%%====================================================
% Electrical Angle
%%====================================================

theta = 2*pi*f*t;

%%====================================================
% Three Phase Reference Voltages
%%====================================================

Va = Vref*sin(theta);

Vb = Vref*sin(theta-2*pi/3);

Vc = Vref*sin(theta+2*pi/3);

%%====================================================
% Clarke Transformation
%%====================================================

Valpha = (2/3)*(Va-0.5*Vb-0.5*Vc);

Vbeta = (2/3)*(sqrt(3)/2)*(Vb-Vc);

%%====================================================
% Reference Vector Magnitude
%%====================================================

Vref_mag = sqrt(Valpha.^2 + Vbeta.^2);

%%====================================================
% Reference Vector Angle
%%====================================================

Theta = atan2(Vbeta,Valpha);

Theta(Theta<0)=Theta(Theta<0)+2*pi;

Theta_deg = Theta*180/pi;

%%====================================================
% Sector Identification
%%====================================================

Sector = floor(Theta/(pi/3))+1;

Sector(Sector==7)=6;

%%====================================================
% Region Identification (Correct)
%%====================================================

Region = zeros(1,N);

m1 = zeros(1,N);
m2 = zeros(1,N);

for k = 1:N

    % Local angle (Eq.15)
    theta_local = Theta(k) - (Sector(k)-1)*pi/3;

    if theta_local < 0
        theta_local = theta_local + pi/3;
    end

    % Eqs. (9) and (10)
    m1(k) = ma*(cos(theta_local)-sin(theta_local)/sqrt(3));

    m2(k) = 2*ma*sin(theta_local)/sqrt(3);

    % Region conditions
    if (m1(k)<=1) && ((m1(k)+m2(k))<=1)

        Region(k)=1;

    elseif (m1(k)<=1) && ((m1(k)+m2(k))>1)

        Region(k)=2;

    elseif (m1(k)>1)

        Region(k)=3;

    elseif (m2(k)>1)

        Region(k)=4;

    end

end
%%====================================================
% Kim-Sul Timing Calculation
%%====================================================

Tas = zeros(1,N);
Tbs = zeros(1,N);
Tcs = zeros(1,N);

Tmax = zeros(1,N);
Tmin = zeros(1,N);

Teff = zeros(1,N);
Tzero = zeros(1,N);
Toffset = zeros(1,N);

Tga = zeros(1,N);
Tgb = zeros(1,N);
Tgc = zeros(1,N);

for k = 1:N

    %% Equivalent Time Signals

    Tas(k) = Ts*Va(k)/Vdc;
    Tbs(k) = Ts*Vb(k)/Vdc;
    Tcs(k) = Ts*Vc(k)/Vdc;

    %% Maximum and Minimum

    Tmax(k) = max([Tas(k) Tbs(k) Tcs(k)]);

    Tmin(k) = min([Tas(k) Tbs(k) Tcs(k)]);

    %% Effective Time

    Teff(k) = Tmax(k)-Tmin(k);

    %% Zero Vector Time

    Tzero(k) = Ts-Teff(k);

    %% Offset Time

    Toffset(k) = Tzero(k)/2-Tmin(k);

    %% Gate ON Times

    Tga(k)=Tas(k)+Toffset(k);

    Tgb(k)=Tbs(k)+Toffset(k);

    Tgc(k)=Tcs(k)+Toffset(k);

end
%%==========================================
% Step 6 : Switching Sequence Selection
%%==========================================



%%==========================================
% Convert Switching Sequence to String
%%==========================================




%%====================================================
% Plot Three Phase Voltages
%%====================================================

figure;

plot(t,Va,'r','LineWidth',1.5);
hold on;
plot(t,Vb,'g','LineWidth',1.5);
plot(t,Vc,'b','LineWidth',1.5);

grid on;

xlabel('Time (s)');
ylabel('Voltage (V)');
title('Three Phase Reference Voltages');

legend('Va','Vb','Vc');

%%====================================================
% Plot Space Vector
%%====================================================

figure;

plot(Valpha,Vbeta,'LineWidth',1.5);

grid on;
axis equal;

xlabel('V_\alpha');
ylabel('V_\beta');

title('Reference Space Vector');

%%====================================================
% Plot Sector
%%====================================================

figure;

stairs(t,Sector,'LineWidth',1.5);

grid on;

xlabel('Time (s)');
ylabel('Sector');

title('Sector Identification');

ylim([0.5 6.5]);

%%====================================================
% Plot Region
%%====================================================

figure;

stairs(t,Region,'LineWidth',1.5);

grid on;

xlabel('Time (s)');
ylabel('Region');

title('Region Identification');

ylim([0.5 4.5]);

%%====================================================
% Plot m1 and m2
%%====================================================

figure;

plot(t,m1,'r','LineWidth',1.5);
hold on;
plot(t,m2,'b','LineWidth',1.5);

grid on;

xlabel('Time (s)');
ylabel('Value');

legend('m1','m2');

title('Region Variables');