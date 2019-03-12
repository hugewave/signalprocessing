clear all;
clc;

siglen_rd = 79*100000;
steps = 1024;
f_info = fopen('burst_info.txt','w');

channelid = 11;
for channelid = 23
    fid = fopen('tmp_all.pcm','r','b');
    fseek(fid,0,'bof');
    fot = fopen('single.pcm','w','b');
    while feof(fid) ~= 1

        sig = fread(fid,siglen_rd,'int16','l')'; 
    %    sig = reshape(sig,79,[]);
        otsig = sig(channelid:79:end);
        fwrite(fot,otsig,'int16','l');
        if length(sig) < siglen_rd
            break;
        end
    end
    fclose(fid);
    fclose(fot);

    fid = fopen('single.pcm','r','b');
    sig = fread(fid,'int16','l')';
    fclose(fid);
    sig_mean = mean(sig);
    thrsld_up = sig_mean*5;
    siglen = length(sig);
    
    status = 0;
    smslen = 10;
    i = smslen + 1;
    otsig = zeros(1,siglen);
    while i < siglen - 100
        if status == 0
            if sig(i) > thrsld_up
                status = 1;
                bgp = i-1;
                thrsld_down = max(sig(bgp:bgp + smslen-1))/2;     
                i = i + smslen;
            else
                i = i + 1;
            end
        else
            if max(sig(i : i + smslen-1)) < thrsld_down
                edp = i-1;
                for k = i-1:-1:i-10
                    if sig(k) > thrsld_down
                         edp = k + 1;
                        break;
                    end
                end
               status = 0;
               i = edp + smslen;
               %otsig (bgp:edp) = 200;
               if (edp - bgp) > smslen
               fprintf(f_info,'%10d   %10d   %10d  %10d\r\n',channelid,(bgp-1)*steps,(edp-1)*steps,(edp-1)*steps - (bgp-1)*steps);
               end
            else
                i = i + 10;
            end
        end
    end
end
fclose('all');
%%
bursts_info = load('burst_info.txt');
rst = zeros(1,length(sig));
for i = 1:size(bursts_info)
    bgp = round(bursts_info(i,2)/1024);
    edp = round(bursts_info(i,3)/1024);
    rst(bgp:edp) = 100;
end

%%
bursts_info = bursts_info(bursts_info(:,1) >= 73 | bursts_info(:,1) <= 22 ,:);
%%
bursts_info = bursts_info(bursts_info(:,end) > 400000,:);
%%
bursts_info = sortrows(bursts_info,2);
%%
plot(sig);
hold on;
plot(otsig);