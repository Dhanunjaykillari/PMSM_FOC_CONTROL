clc;
clear;
close all;

%% ============================================================
% INITIALIZATION
% =============================================================

a  = 1;                 % Sine magnitude
f  = 50;                % Fundamental frequency [Hz]
t  = 1e-5;              % Simulation step [s]
T  = 0:t:0.04;          % Simulation time

fc = 5000;             % Carrier frequency [Hz]

Vmax = zeros(size(T));
Vmin = zeros(size(T));

PWM_A = zeros(size(T));
PWM_B = zeros(size(T));
PWM_C = zeros(size(T));

%% ============================================================
% POSITIVE TRIANGULAR CARRIER : 0 TO 1
% =============================================================

carrier = (2/pi) * asin(sin(2*pi*fc*T));
carrier = (carrier + 1)/2;

%% ============================================================
% ELECTRICAL ANGLE
% =============================================================

theta = 2*pi*f*T;

% Wrapped angle: 0 to 2*pi
theta_wrapped = mod(theta, 2*pi);

%% ============================================================
% THREE-PHASE SINE WAVES
% =============================================================

VA = sin(theta);

VB = sin(theta - 2*pi/3);

VC = sin(theta + 2*pi/3);

%% ============================================================
% SHIFT NEGATIVE PART OF SINE TO POSITIVE SIDE
% =============================================================

VANEW = VA;

VANEW(VANEW < 0) = VANEW(VANEW < 0) + 1;


VBNEW = VB;

VBNEW(VBNEW < 0) = VBNEW(VBNEW < 0) + 1;


VCNEW = VC;

VCNEW(VCNEW < 0) = VCNEW(VCNEW < 0) + 1;

%% ============================================================
% FIND MAXIMUM AND MINIMUM
% =============================================================

for k = 1:length(T)

    Vmax(k) = max([VANEW(k), VBNEW(k), VCNEW(k)]);

    Vmin(k) = min([VANEW(k), VBNEW(k), VCNEW(k)]);

end

%% ============================================================
% COMMON-MODE VOLTAGE
% =============================================================

vcm = (1 - (Vmax + Vmin))/2;

VANEW = VANEW + vcm;

VBNEW = VBNEW + vcm;

VCNEW = VCNEW + vcm;

%% ============================================================
% PWM GENERATION USING THETA
% =============================================================

for k = 1:length(T)

    %% ========================================================
    % PHASE A
    % ========================================================

    theta_A = mod(theta(k), 2*pi);

    if theta_A < pi

        % Positive half-cycle
        if VANEW(k) > carrier(k)
            PWM_A(k) = 1;
        else
            PWM_A(k) = 0;
        end

    else

        % Negative half-cycle
        if VANEW(k) < carrier(k)
            PWM_A(k) = -1;
        else
            PWM_A(k) = 0;
        end

    end


    %% ========================================================
    % PHASE B
    % ========================================================

    theta_B = mod(theta(k) - 2*pi/3, 2*pi);

    if theta_B < pi

        % Positive half-cycle
        if VBNEW(k) > carrier(k)
            PWM_B(k) = 1;
        else
            PWM_B(k) = 0;
        end

    else

        % Negative half-cycle
        if VBNEW(k) < carrier(k)
            PWM_B(k) = -1;
        else
            PWM_B(k) = 0;
        end

    end


    %% ========================================================
    % PHASE C
    % ========================================================

    theta_C = mod(theta(k) + 2*pi/3, 2*pi);

    if theta_C < pi

        % Positive half-cycle
        if VCNEW(k) > carrier(k)
            PWM_C(k) = 1;
        else
            PWM_C(k) = 0;
        end

    else

        % Negative half-cycle
        if VCNEW(k) < carrier(k)
            PWM_C(k) = -1;
        else
            PWM_C(k) = 0;
        end

    end

end

%% ============================================================
% VOLTAGES
% =============================================================

VLINE = PWM_A - PWM_B;

VN = (PWM_A + PWM_B + PWM_C)/3;

VPH = PWM_A - VN;


%% ============================================================
% PLOT 0-1 MAGNITUDE REFERENCES
% =============================================================

figure;

plot(T, VANEW, 'LineWidth', 1.2);
hold on;

plot(T, VBNEW, 'LineWidth', 1.2);
plot(T, VCNEW, 'LineWidth', 1.2);

grid on;

xlabel('Time (s)');
ylabel('Magnitude');

legend('VANEW','VBNEW','VCNEW');

title('Three-Phase Positive-Only References');



%% ============================================================
% PLOT LINE AND PHASE VOLTAGES
% =============================================================

figure;


plot(T, VPH, 'LineWidth', 1.2);

grid on;

xlabel('Time (s)');
ylabel('Voltage');

legend('VPH');

title('Line and Phase Voltages');
%% ============================================================
% ONE-SIDED FFT AND THD - PHASE VOLTAGE (VPH)
% ============================================================

Fs = 1/t;                      % Sampling frequency
N  = length(VPH);              % Number of samples

% Remove DC component
V = VPH - mean(VPH);

%% FFT

Y = fft(V);

% Two-sided spectrum
P2 = abs(Y/N);

% One-sided spectrum
P1 = P2(1:floor(N/2)+1);

% Correct amplitude for one-sided FFT
P1(2:end-1) = 2*P1(2:end-1);

% Frequency axis
f_axis = Fs*(0:floor(N/2))/N;

%% ONE-SIDED DISCRETE FFT PLOT

figure;

stem(f_axis, P1, 'filled');

grid on;

xlabel('Frequency (Hz)');
ylabel('Voltage Magnitude');

title('One-Sided FFT of Phase Voltage');

xlim([0 10000]);


%% ============================================================
% THD CALCULATION
% ============================================================

f1 = 50;                       % Fundamental frequency

% Find fundamental frequency index
[~, fund_idx] = min(abs(f_axis - f1));

% Fundamental RMS
V1_rms = P1(fund_idx)/sqrt(2);

% Total RMS (excluding DC)
Vtotal_rms = sqrt(sum(P1(2:end).^2)/2);

% Harmonic RMS
Vharm_rms = sqrt(Vtotal_rms^2 - V1_rms^2);

% THD
THD_VPH = (Vharm_rms/V1_rms)*100;

fprintf('Phase Voltage THD = %.2f %%\n', THD_VPH);