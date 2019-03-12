function search_results = freq_domain_sig_search(sig,fs,fftlen)
search_results = [];
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
%%%%% search bursts in freq domain
threshold_floor = avg_p * 3;
s_2_floor = fftot - threshold_floor;
s_2_floor(s_2_floor > 0) = 1;
s_2_floor(s_2_floor <= 0) = 0;
i = freqbgp ;
state = 0;
rslts = [];
while i < freqedp
    if state ==0
        if s_2_floor(i) == 1
            bgp = i;
            state = 1;
        end
    else
        if s_2_floor(i) == 0
            edp = i-1;
            rslts = [rslts;[bgp edp]];
            state = 0;
        end
    end
    i = i + 1;
end
%%%% end of searching
search_num = size(rslts,1);
if search_num == 0
    return;
end

for m = 1 : search_num
   slts = rslts(m,:);
   bgp = slts(1);
   edp = slts(2);
[mv,pos] = max(fftot(bgp:edp));
pos = pos + bgp - 1;
peak_2_avg = mv/avg_p;
threshold_3db = mv/2;
    up = pos;
    down = pos;
    for i = 1:(edp-pos+1)
        if fftot(up+1) < threshold_3db
            break;
        end
        up = up + 1;
    end
    for i = 1:(pos-bgp+1)
        if fftot(down-1) < threshold_3db
            break;
        end
        down = down - 1;
    end
    bw_3db = (up - down + 1)/fftlen*fs; 
    bw = bw_3db;
    fc = pos/fftlen*fs;
    fc = round(fc /1e6) * (1e6);
    search_results = [search_results ;[fc bw peak_2_avg]];
end
end