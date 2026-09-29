clc;
clear;
close all;

%% =========================================================
% BOOST CONVERTER PARAMETERS
% =========================================================
Vin = 48;               % Input voltage (V)
L   = 6e-3;           % Inductor (H)
C   = 100e-6;           % Capacitor (F)
R   = 100;              % Load resistance (Ohm)
D   = 0.52;              % Duty ratio
vo = Vin/(1-D);

s = tf('s');

%% =========================================================
% BOOST CONVERTER CONTROL-TO-OUTPUT TRANSFER FUNCTION
% Gvd(s) = Vo(s)/D(s)
% =========================================================

Gvd = (Vin/(1-D)^2) * ...
      (1 - s*L/(R*(1-D)^2)) / ...
      (s^2*L*C + s*L/(R*(1-D)^2) + 1);

Gvd = minreal(Gvd);

disp('==========================================');
disp('BOOST CONVERTER TRANSFER FUNCTION');
disp('==========================================');
Gvd


%% =========================================================
% RHP ZERO AND LC RESONANT FREQUENCY
% =========================================================

wz = R*(1-D)^2/L;
w0 = 1/sqrt(L*C);

fprintf('RHP Zero       = %.2f rad/s\n',wz);
fprintf('RHP Zero       = %.2f Hz\n',wz/(2*pi));

fprintf('Resonant freq. = %.2f rad/s\n',w0);
fprintf('Resonant freq. = %.2f Hz\n',w0/(2*pi));


%% =========================================================
% PI CONTROLLER PARAMETERS
% =========================================================

fc = 150;                % Desired crossover frequency (Hz)
PM = 60;                % Desired phase margin (degrees)

wc = 2*pi*fc;           % Crossover frequency (rad/s)

% Plant magnitude and phase at crossover frequency
[mag,phase] = bode(Gvd,wc);

mag   = squeeze(mag);
phase = squeeze(phase);

Gp = mag * exp(1j*deg2rad(phase));

% Required loop phase
target_phase = -180 + PM;

target = exp(1j*deg2rad(target_phase));

% Required controller at crossover
Gc_req = target/Gp;

% PI controller:
% Gc(s) = Kp + Ki/s
%       = (Kp*s + Ki)/s

Kp = real(Gc_req);
Ki = -imag(Gc_req)*wc;

fprintf('\n==========================================');
fprintf('\nPI CONTROLLER');
fprintf('\n==========================================\n');

fprintf('Kp = %.6f\n',Kp);
fprintf('Ki = %.6f\n',Ki);


%% =========================================================
% PI CONTROLLER TRANSFER FUNCTION
% =========================================================

Gc = Kp + Ki/s;

disp(' ');
disp('PI Controller Gc(s) = ');
Gc


%% =========================================================
% OPEN LOOP TRANSFER FUNCTION
% =========================================================

Gol = Gc * Gvd;
Gol = minreal(Gol);

disp('==========================================');
disp('OPEN LOOP TRANSFER FUNCTION');
disp('==========================================');

Gol


%% =========================================================
% BODE / PHASE MARGIN
% =========================================================

figure;
margin(Gol);
grid on;

title('Boost Converter Open-Loop Transfer Function');


%% =========================================================
% CLOSED LOOP TRANSFER FUNCTION
% =========================================================

T = feedback(Gol,1);
T = minreal(T);

disp('==========================================');
disp('CLOSED LOOP TRANSFER FUNCTION');
disp('==========================================');

T


%% =========================================================
% CLOSED LOOP STEP RESPONSE
% =========================================================

figure;
step(T);
grid on;

title('Closed Loop Step Response');