function [fc,bw,peak_2_avg] = single_hop_est(sig,fs,fftlen)
fftot = zeros(1,fftlen);
siglen = length(sig);
pronum = siglen/fftlen;
for i = 1:pronum
    ftsig = sig(((i-1)*fftlen+1:i*fftlen));
    fftot = fftot + abs(fft(ftsig,fftlen)); 
end
fftot = fftot(1:fftlen/2);
%plot(fftot);
freqbgp = round(10e6/fs*fftlen);%in fft
freqedp = round(90e6/fs*fftlen);
avg_p = mean(fftot(freqbgp:freqedp));
[mv,pos] = max(fftot);
peak_2_avg = mv/avg_p;
threshold_3db = mv/2;
%if search_rslt == 1
    up = pos;
    down = pos;
    for i = 1:10
        if fftot(up+1) < threshold_3db
            break;
        end
        up = up + 1;
    end
    for i = 1:10
        if fftot(down-1) < threshold_3db
            break;
        end
        down = down - 1;
    end
%end
bw_3db = (up - down + 1)/fftlen*fs; 
bw = bw_3db;
fc = pos/fftlen*fs;
end