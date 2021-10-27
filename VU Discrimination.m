


% Step 1: Endpoint Detected - as separate Speech signal and Silence
% Method: Break signal into frames of 0.1 seconds 
% Read Signal To variable Sample with frequency Fs
[Sample , Fs] = audioread('E:\Tài liệu đại học\Xử lí tín hiệu số\BT nhom\TinHieuHuanLuyen\lab_female.wav');
% Nomalize Data
Sample = Sample / abs(max(Sample));
% Choose the frame 
frame_duration = 0.1;
frame_len = frame_duration * Fs; 
N = length(Sample);
Num_frame = floor(N / frame_len);

% Create new signal include speech signal
NotSilenceSignal = [N, 1];
% We can divide Sample to frame by method 
% Frame1 = Sample(1 : frame_len);
% Frame2 = Sample(frame_len + 1 : frame_len * 2);
% Frame3 = Sample(frame_len * 2 + 1: frame_len * 3); 
% So we can do this with for loop
count = 0;
for i = 1 : Num_frame
    frame = Sample((i - 1) * frame_len  + 1 : frame_len * i);
    
    % Base on Original Signal we choose max amplitude is 0.04 to identify
    % the non silence frame 
    max_val = max(frame);
    if (max_val > 0.04)
        % it is frame not silence  
        count = count + 1;
        NotSilenceSignal((count - 1) * frame_len + 1 : frame_len * count) = frame;
    end
end

%Step 2: After get new Signal from the Method Frame by Frame to removal
%Silence Signal, We haming windows and Calculator STE of Signal and plot the STE  
% Choose the haming windows to plot STE
winLen = 301;
winOverlap = 300;
winHamming  = hamming(winLen);

% Continuous frame by frame and windows not need loop 
sigFrames = buffer(NotSilenceSignal, winLen, winOverlap, 'nodelay');
% Buffer: Specifies a vector of Samples to precede NotSilenceSignal(1) 
% in overlap buffer
% nodelay : opt of Buffer to skip the initial condition an filling buffer
% immediately with NotSilenceSigna(1)
sigWindow = diag(sparse(winHamming)) * sigFrames;
% Take windows by diagonal sparse winhamming Matrix * sigFrames

% Short time energy - STE 
STenergy = sum(sigWindow.^2);
STenergy = STenergy./ abs(max(STenergy));
% Get time of NotSilenceSignal 
time = [1 : length(NotSilenceSignal)] / Fs;

% Plot STE with Time 
% We plot NotSilenceSignal First 
subplot(1, 1, 1);
plot(time, NotSilenceSignal);
title('Not Silence Signal, Combine Voice/Unvoice');
xlims = get(gca, 'Xlim');

hold on;
delay = (winLen - 1) / 2;
plot(time(delay+1 : end - delay), STenergy, 'r');
xlim(xlims);
xlabel('Time (s)');

%Step 3: Calculate ZCR and plot it
% Zero Crossing Rate - ZCR
ZCR = sum(abs(diff(sigWindow >= 0)));
ZCR = ZCR./ abs(max(ZCR));

hold on; 
plot(time(delay + 1 : end - delay), ZCR/max(ZCR), 'g');
legend('Speech', 'Short-Time Energy' ,'Zero Crossing Rate');
hold off;


% %Step 4: Make decision for Voice/Unvoice on table and Plot the
% %boundaries to dicrimination it
% % Get value of sigFrames 
% [n m] = size(sigFrames);
% decision = {};
% voiceSample = 0;
% unvoiceSample = 0;
% voiceSignal = [];
% unvoiceSignal =[];
% count1 = 0;
% count2 = 0;
% for i = 1:m
%     %Why choose 0.5 beacause base on plot(STenergy) to choose the value
%    if (STenergy(i) > 0.5 && ZCR(i) < 30)
%        decision = 'Voice';
%        voiceSignal = cat(2, voiceSignal, sigFrames(:, 1));
%        if(voiceSample == 0)
%            voiceSample = i;
%        end
%    else
%        decision = 'Unvoice';
%        % Concatenate Array with dimension 2
%        unvoiceSignal = cat(2, unvoiceSignal, sigFrames(:, 1));
%        if(unvoiceSample == 0)
%           unvoiceSample = i;
%        end
%    end
% end
% 
% %draw table
% f = figure(2);
% datacells = [num2cell((1:m)'),num2cell(ZCR'),num2cell(STenergy'),cellstr(decision')];
% cname = {'Frame', 'ZCR', 'STE', 'Decision'};
% tTable = uitable(f,'Data',datacells,'ColumnName',cnames,'Position',[50 100 400 200],'FontSize',12);
% 
% %plot boundaries to dicrimination Voice / Unvoice 
% figure(3);
% plot(time, NotSilenceSignal);
% t1 = 'V'; t2 = 'UV';
% for i=1 : m
%     if (i == voiceSample)
%         y = ylim;
%         xline(i);
%         set(h1, 'FontSize', 8);
%     else
%         xline(i);
%         set(h2, 'FontSize', 8);
%     end
% end











