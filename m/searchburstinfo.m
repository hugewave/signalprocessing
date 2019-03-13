    function [burst_bg,burstlen] = searchburstinfo(sig,smslen)
    %searchburstinfo  searching burst infos
    %searching the burst infos with the double window method
    mo_sig = abs(sig);
    sms_flt = ones(1,smslen);
    mo_fltot = conv(mo_sig,sms_flt);
    mo_fltot = mo_fltot(smslen:end-smslen+1);
    div_mo = mo_fltot(smslen+1:end)./mo_fltot(1:end-smslen);
    [~,bg] = max(div_mo);
    [~,ed] = min(div_mo);
    bg = bg + smslen;
    ed = ed + smslen;
    eng_threshold = mean(mo_fltot(bg:ed))/2;
    for i = bg:-1:1
        if mo_fltot(i) < eng_threshold
            break;
        end
    end
    burst_bg = i;
    for i = ed : length(mo_fltot)
        if mo_fltot(i) < eng_threshold    
            break;
        end
    end
    burst_ed = i;
    %burst_bg = bg + smslen +smslen/2;
    burst_bg = burst_bg + smslen/2;
    burstlen = burst_ed - burst_bg;
    end