%---------- Example for incremental fitting ----------
load CurveExample.mat

data = cdata;

nFrames = size(data,1);
time = 60*(0:(nFrames-1));

%% find maximum value
[maxValue, maxIndex] = max(data);
%maxIndex = maxIndex+2;
if(maxIndex > nFrames)
    maxIndex = nFrames;
end
maxValue = maxValue+1;

%% usual fit
% exponential part
yApprox1 = zeros(maxIndex,1);
if(maxIndex > 3)
    tic;
    [slope, intercept, MSE1] = logfit(time(1:maxIndex)+1, -log10(-data(1:maxIndex)./ maxValue + 1), 'linear');
    yApprox1 = maxValue .* (1-(10^(-intercept))*(10^(-slope)).^(time(1:maxIndex)+1));
    t1 = toc;
end

% linear part
slope2 = 0;
intercept2 = 0;
MSE2 = 0;
beta = [0 0];
if(maxIndex < nFrames-2)
    [slope2, intercept2, MSE2] = logfit(1+time(maxIndex:end), data(maxIndex:end), 'linear');
end
yApprox2 = intercept2+slope2*(time(maxIndex:end)+1);



%% plot
f = plot(1:nFrames,data, 'k'); xlabel('Time(s)'); ylabel('Projected value'); %set(f,'linewidth',4);
hold on;
h = plot(1:maxIndex,yApprox1, 'b');
h = plot(maxIndex:nFrames,yApprox2,'b'); title('Curve with usual fitting results. Press enter');
pause;


%% IMSR: incremental fit
windowSize = 1;
M = zeros(2,2);
V = zeros(2,1);

t2 = 0;

% exponential part
for i = 1:windowSize:maxIndex
    window = windowSize-1;
    
    % reduce window if it covers more than the available samples
    if(i > maxIndex-window)
        window = maxIndex-i;
    end
    
    tic;
    % parameters for least-squares
    X = time(i:i+window)'+1;
    tX = [ones(window+1,1) X];
    %y = -log10(-data(i:i+window)./ maxValue + 1);
    y = log10(maxValue) - log10(maxValue-data(i:i+window));
    
    M = M + tX'*tX;
    V = V + tX'*y;
    t2 = t2 + toc;
    
    % === COMMENT TO SEE ONLY THE FINAL RESULT ===
%     % least-squares
%     beta2 = -(M \ V);
%     yAp2 = maxValue .* (1-(10^beta2(1))*(10^beta2(2)).^(time(1:i+window)+1));
%     
%     plot(1:i+window,yAp2,'g'); title('Incremental fitting. Press enter'); pause;
    % ============================================
end

% least-squares
tic;
beta2 = -(M \ V);
yAp2 = maxValue .* (1-(10^beta2(1))*(10^beta2(2)).^(time(1:maxIndex)+1));
t2 = t2+toc;

% linear part
M = zeros(2,2);
V = zeros(2,1);
for i = maxIndex:windowSize:nFrames
    window = windowSize-1;
    if(i > nFrames-window)
        window = nFrames-i;
    end
    
    X = time(i:i+window)'+1;
    tX = [ones(window+1,1) X];
    y = data(i:i+window);
    
    M = M + tX'*tX;
    V = V + tX'*y;
    
    % === COMMENT TO SEE ONLY THE FINAL RESULT ===
%     % least-squares
%     beta2 = M \ V;
%     yAp3 = beta2(1) + beta2(2)*(time(maxIndex:i+window)+1);
%     plot(maxIndex:i+window,yAp3,'g'); title('Incremental fitting. Press enter'); pause;
    % ============================================
end

% least-squares
beta3 = M \ V;
yAp3 = beta3(1) + beta3(2)*(time(maxIndex:i+window)+1);



%% plot
h = plot(1:maxIndex,yAp2,'r'); set(h,'linewidth',2);
h = plot(maxIndex:nFrames,yAp3,'r'); set(h,'linewidth',2);
title('Incremental fitting result in red');
hold off; pause; close;






