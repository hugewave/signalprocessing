clear all;
clc;
fid = fopen('E:\BaiduNetdiskDownload\反复配对.pcm','r','b');
bgp = 0;
steps = 1024;
fs = 200e6;
fftlen = 1024;
freqsets = 2402:2480;
fcs = 12e6:1e6:90e6;
frqs = round(fcs/fs*fftlen) + 1;
wd = blackman(fftlen)';
blk_buf_size = 1e6;
db_buf = zeros(1,blk_buf_size*2);
sig = fread(fid,blk_buf_size*2,'int16','l')'; 
db_buf = sig;
wk_status = 1;
abslt_pos = 1;
rela_pos = 1;
tmpbuf = zeros(79,round(blk_buf_size/steps)+200);
fot = fopen('E:\BaiduNetdiskDownload\amp_反复配对.pcm','w','b');
while wk_status
    if feof(fid)
        break;
    end
    
    tmpnum = 0;
    while rela_pos < (blk_buf_size +1)
        sig = db_buf(rela_pos : rela_pos + fftlen-1);
        ftsig = abs(fft(sig.*wd,fftlen));
        tmpbuf(:,tmpnum+1) = ftsig(frqs)'/16;
        tmpnum = tmpnum + 1;
        rela_pos = rela_pos + steps;
    end
    tmmmp = tmpbuf(:,1:tmpnum);
    tmmmp = reshape(tmmmp,1,[]);
    fwrite(fot,tmmmp,'int16','l');
    
    rela_pos = rela_pos - blk_buf_size;
    tmpsig =  fread(fid,blk_buf_size,'int16','l')';
    if length(tmpsig) < blk_buf_size
        break;
    end
    db_buf(1:blk_buf_size) = db_buf(blk_buf_size+1:end);
    db_buf(blk_buf_size+1:end) = tmpsig;
end
fclose('all');