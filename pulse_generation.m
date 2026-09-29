clc
clear
close all

%% time (2 seconds)
Fs = 1e6;                 % sampling frequency
t = 0:1/Fs:2;             % time duration

%% frequencies
f_sine = 50;              
f_carrier = 1000;         

%% sine magnitude = 0.8
sine_wave = 0.8*sin(2*pi*f_sine*t);

%% shift negative part upward (no flipping)
final_wave = sine_wave;
final_wave(final_wave < 0) = final_wave(final_wave < 0) + 1;

%% carrier waveform (0 → 1 → 0)
carrier_wave = (sawtooth(2*pi*f_carrier*t,0.5)+1)/2;

%% comparison conditions

% pulse when sine > carrier (upper switch)
pulse_high = final_wave > carrier_wave;

% pulse when sine < carrier (lower switch)
pulse_low  = final_wave < carrier_wave;

%% plots in single page

figure

% 1 modified sine
subplot(4,1,1)
plot(t,final_wave,'b','LineWidth',1.5)
title('Modified sine waveform')
ylabel('Amplitude')
ylim([0 1])
grid on


% 2 carrier
subplot(4,1,2)
plot(t,carrier_wave,'r','LineWidth',1)
title('Carrier waveform')
ylabel('Amplitude')
ylim([0 1])
grid on


% 3 pulse for > comparison
subplot(4,1,3)
plot(t,pulse_high,'k','LineWidth',1)
title('Pulse when sine > carrier (upper switch)')
ylabel('Pulse')
ylim([0 1])
grid on


% 4 pulse for < comparison
subplot(4,1,4)
plot(t,pulse_low,'m','LineWidth',1)
title('Pulse when sine < carrier (lower switch)')
xlabel('Time (sec)')
ylabel('Pulse')
ylim([0 1])
grid on