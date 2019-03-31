function [rslt,demo_out] = judge_ble(demobits,freqid)
%judge_ble judge if the signal is ble
% judge with the frequency id and the demo bits
% rslt: 0 --> br/edr 1 --> ble  -1 --> not br/edr/ble
demo_out = demobits;

pronum  = min(30,length(demobits)-67);
rslt = -1;

for i = 1 : pronum
    tmp = demobits(i : i + 7);
    tmp_hd = sum(mod(tmp(1:8) + [1 0 1 0 1 0 1 0],2));
    if tmp_hd == 8 || tmp_hd == 0
        rslt = 1;
        demo_out = demobits(i:end);
        break;
    end
end

for i = 1 : pronum
    tmp = demobits(i : i + 67);
    tmp_hd = sum(mod(tmp(1:5) + [1 0 1 0 1],2));
    tmp_tl = sum(mod(tmp(end-6:end) + [1 1 1 0 0 1 0],2));
    hdok = 0;
    tlok = 0;
    if tmp_hd == 5 || tmp_hd == 0
        hdok = 1;
    end
    if tmp_tl == 7 || tmp_tl == 0
        tlok = 1;
    end
    if (hdok + tlok) == 2
        if (length(demobits) - 49) < (i + 71)%sig is short without head
            if rslt == 1
                return;
            else
                rslt = 0;
                demo_out = demobits(i:end);
                return;
            end
        else
            head = demobits(i + 72 : i + 72 + 47);
            head = reshape(head,3,[]);
            sm_hd = sum(mod(sum(head),3));
            tmp = demobits(i + 67 : i + 71);
            s_tail = sum(mod(tmp + [1 0 1 0 1],2)); 
            if (s_tail == 5 || s_tail == 0 ) && sm_hd ==0
                 rslt = 0;
                 demo_out = demobits(i:end);
                 return;
            end
        end
    end
end

% if mod(freqid,2) == 0
%     rslt = 0;
%     return;
% end

% for i = 1 : pronum
%     tmp = demobits(i : i + 7);
%     tmp_hd = sum(mod(tmp(1:8) + [1 0 1 0 1 0 1 0],2));
%     if tmp_hd == 8 || tmp_hd == 0
%         rslt = 1;
%         demo_out = demobits(i:end);
%         return;
%     end
% end
% 
% rslt = -1;

end

