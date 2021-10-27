% list of directory to the file storage the wav file 
audio1 = 'E:\Tài liệu đại học\Xử lí tín hiệu số\BT nhom\TinHieuKiemThu\phone_F2.wav';
audio2 = 'E:\Tài liệu đại học\Xử lí tín hiệu số\BT nhom\TinHieuKiemThu\phone_M2.wav';
audio3 = 'E:\Tài liệu đại học\Xử lí tín hiệu số\BT nhom\TinHieuKiemThu\studio_F2.wav';
audio4 = 'E:\Tài liệu đại học\Xử lí tín hiệu số\BT nhom\TinHieuKiemThu\studio_M2.wav';

% the result of Unvoice from file Lab, this raw is setup for signal after
% cut silence signal
PhoneF2_Lab = [0.9 0.97 1.17 1.26 1.57 1.72 2.26 2.3 2.37 2.54 2.67 2.78 2.88 2.92];
PhoneM2_Lab = [0.55 0.62 0.75 0.82 0.92 1.12 1.4 1.47 1.53 1.58 1.71 1.84 1.89 1.91];
StudioF2_Lab = [0.49 0.51 0.56 0.61 0.97 1.04 1.11 1.19];
StudioM2_Lab = [0 0.03 0.33 0.35 0.43 0.47 0.86 0.92 1.07 1.13];

%Call function to execution for plot each audio signal list (eg audio1, audio2,...)
%Function include the lab result like (PhoneF2_Lab, PhoneM2_Lab, ...)
%Return Threshold for Function to execution like (Threshold_PhoneM2)
figure('Name', 'Signal Phone Female');
[Threshold_PhoneF2] = AnalysisAudio(audio1, PhoneF2_Lab);
figure('Name', 'Signal Phone Male');
[Threshold_PhoneM2] = AnalysisAudio(audio2,  PhoneM2_Lab);
figure('Name', 'Signal Studio Female');
[Threshold_StudioF2] = AnalysisAudio(audio3, StudioF2_Lab);
figure('Name', 'Signal Studio Male');
[Threshold_StudioM2] = AnalysisAudio(audio4, StudioM2_Lab);

function [Threshold] = AnalysisAudio(audio, TestInput)
% Step 1: Endpoint Detected - as separate Speech signal and Silence
% Method: Break signal into frames of 0.02 seconds 
% Read Signal To variable Sample with frequency Fs
[Sample , Fs] = audioread(audio);
% Nomalize Data
Sample = Sample./ abs(max(Sample));
% Choose the frame 
frame_duration = 0.020;
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
    
    % Base on Original Signal we choose max amplitude is 0.03 to identify
    % the non silence frame 
    max_val = max(frame);
    if (max_val > 0.03)
        % it is frame not silence  
        count = count + 1;
        NotSilenceSignal((count - 1) * frame_len + 1 : frame_len * count) = frame;
    end
end

% Step 2: After get new Signal from the Method Frame by Frame to removal
%Silence Signal, Calculator STE of Signal and plot the STE
%Continious Frame by Frame signal 
%Choose the frame 
NotSilenceSignal = NotSilenceSignal./ abs(max(NotSilenceSignal)); % nomalize data
Speechframe_duration = 0.020;
Speechframe_len = Speechframe_duration * Fs; 
NSpeech = length(NotSilenceSignal);
Num_Speechframe = floor(NSpeech / Speechframe_len);
for i = 1 : Num_Speechframe
    % framing and storage it in Speechframes
    Speechframes(i,:) = NotSilenceSignal((i - 1) * Speechframe_len + 1 : Speechframe_len * i);
    %Speechframes(i,:) = NotSilenceSignal(countSpeech + 1 : Speechframe_len + countSpeech);
    %countSpeech = countSpeech + Speechframe_len;
end
EnergyPerframe = zeros(1,Num_Speechframe);     
for i=1:Num_Speechframe
    %STE compute by sum of speech from sinal with pow of 2
    EnergyPerframe(i) = sum(Speechframes(i,:).^2);
end
EnergyPerframe = EnergyPerframe./abs(max(EnergyPerframe)); % continious nomalize data
STE_Wave = 0;
for i = 1 : length(EnergyPerframe)
    % Take len when loop back of STE_Wave
    % Create the STE_wave to use for plot the STE 
    STEWave_len  = length(STE_Wave);
    STE_Wave(STEWave_len : STEWave_len + Speechframe_len) = EnergyPerframe(i);
end

% plot the STE with Time
time = [1 : length(NotSilenceSignal)] / Fs;
timeWave = [1 : length(STE_Wave)] / Fs;    

% plot the NotSilenceSignal First 
subplot(2, 1, 1);
plot(time , NotSilenceSignal);
title('Voice/Unvoice from Original Signal');
xlims = get(gca, 'Xlim'); % Get current limit of x-axis 

hold on;
plot(timeWave, STE_Wave, 'r');
xlim(xlims); %xlim(limits) sets the x-axis limits for the current axes or chart
xlabel('Time (s)');

% Step 3: Calculate ZCR and plot with time 
% Zero cross rate - ZCR 

for i = 1: Num_Speechframe
    valuefromSpeechSignal = Speechframes(i,:);
    %STE compute by sum of value of the diff (tích phân) between of the
    %frame speech signal
    ZCRPerframe(i) = sum(abs(diff(valuefromSpeechSignal > 0)));
end
ZCRPerframe = ZCRPerframe./ abs(max(ZCRPerframe)); %continious  nomalize data
ZCR_Wave = 0;
for i = 1: length(ZCRPerframe)
    %Take len of ZCR_Wave when loop back
    ZCRWave_len = length(ZCR_Wave);
    ZCR_Wave(ZCRWave_len : ZCRWave_len + Speechframe_len) = ZCRPerframe(i);
end

%plot ZCR with time
hold on;
plot(timeWave, ZCR_Wave, 'g');
legend('Speech Signal', 'Short-time Energy', 'Zero Cross Rate');
hold off;

% Step 4: Make decision about Voice/Unvoice to View it to Table and plot
% line as frame 

[n , m] = size(Speechframes);
decision = {};
voiceSignal = [NSpeech, 1];
unvoiceSignal = [NSpeech, 1];
voiceSample = 0;
unvoiceSample = 0;
countVoice = 0;
countUnvoice = 0;
countline = 1; % the variable to storage the positon to plot xline 

%Threshold of each signal
Threshold = SetThreshold(EnergyPerframe);
%plot line boundaries split voice and unvoice 
subplot(2, 1, 2);
p1 = plot(time , NotSilenceSignal);
for i=1: n
    %Condition to make decision for frame is Unvoice or Voice
    %This condition is used to make decision for Voice Frame
    if (EnergyPerframe(i) > SetThreshold(EnergyPerframe) && ZCRPerframe(i) < 0.4)
        decision{i} = 'Voice';
        voiceframe = NotSilenceSignal((i - 1) * m + 1 : m * i);
        countVoice = countVoice + 1;
        voiceSignal((countVoice - 1) * m + 1 : m * countVoice) = voiceframe;
        hold on;
        p2 = xline(Speechframe_duration * countline , '-r');
        if (voiceSample == 0)
            voiceSample = i;
        end
        countline = countline + 1;
    else
        decision{i} = 'Unvoice';
        unvoiceframe = NotSilenceSignal((i - 1) * m + 1 : m * i);
        countUnvoice = countUnvoice + 1;
        unvoiceSignal((countUnvoice - 1) * m + 1 : m * countUnvoice) = unvoiceframe;
        hold on;
        p3 = xline(Speechframe_duration * countline , '-g', 'LineWidth', 2);
        if (unvoiceSample == 0)
            unvoiceSample = i;
        end
        countline = countline + 1;
    end
end

% Plot Lab Result 
hold on;
for i =1:length(TestInput)/2
      p4 = xline(TestInput(2*i-1), 'k','LineWidth', 2);
      xline(TestInput(2*i), 'k','LineWidth', 2);
end
legend([p1, p2, p3 ,p4],{'Signal', 'Voice', 'Unvoice', 'Lab UV Result'});

%draw table 
% f = figure(3);
% datacells = [num2cell((1:n)'), num2cell(ZCRPerframe'), num2cell(EnergyPerframe'), cellstr(decision')];
% nameColumns = {'Frame', 'ZCR', 'STE', 'Decision'};
% stasticTable = uitable('Data',datacells,'ColumnName',nameColumns,'FontSize',12);
end

% Function to compute the threhold base on Energy per frame 
% Algorithm owner make
% Idea : Thực hiện việc đo lường tín hiệu bằng phương pháp đệ quy, do matlab
% khó thực hiện đệ quy nên tinh chỉnh thành vòng lặp while để xử lí liên
% tục. Ở đây thuật toán được để xuất cách:
% --Step 1: Thực hiện việc lấy biên độ Max, Min của tập giá trị STE đối với tín
% hiệu
% --Step 2: Thực hiện gắn biến t = (max biên - min biên ) / 2 để lưu giá trị
% đầu tiên
% --Step 3 : Thực hiện việc loop để thực hiện liên tục phép tính gán t = (t -
% min value) / 2 để lấy giá trị trung bình 
% --Step 4: Kiểm tra sai số đến một lúc giá trị t(Threshold) - biên min của tín hiệu
% Sao cho sai số nhỏ hơn 0.01(sai số duyệt theo giá trị của kết quả đọc từ
% file lab). Thì xuất ra kết quả Threshold value = t 
% Nếu không thì lặp lại Step 3
% --(P/S : Việc đề xuất dựa trên tín hiệu thu được và tín hiệu ngoài để đưa ra chuẩn tối 
% ưu cho giá thuật toán, để có thể tinh chỉnh chính xác thì ta điều chỉnh sai số sao
% hợp lí nhất thì giá trị ngưỡng Threshold Value sẽ chính xác hơn)
function [STEThreshold] = SetThreshold(Energy)
    max_value = max(Energy);
    min_value = min(Energy);
    t = (max_value - min_value) / 2;
    % Choose the value +- 0.01 compare with t value for order the STD and
    % choose Threshold
    while 1
        t = (t - min_value) / 2;
        if (abs(t - min_value) < 0.01)
            STEThreshold = t;
            break;
        end
    end
end
