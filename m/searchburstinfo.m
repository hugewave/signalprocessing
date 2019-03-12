    function [burst_bg,burstlen] = searchburstinfo(sig,smslen)
    %searchburstinfo  searching burst infos
    %searching the burst infos with the double window method
    mo_sig = abs(sig);
    sms_flt = ones(1,smslen);
    mo_fltot = conv(mo_sig,sms_flt);
    mo_fltot = mo_fltot(1:end-smslen);
    div_mo = mo_fltot(smslen*2-1:end-smslen*2)./mo_fltot(smslen:end-smslen+1-smslen*2);
    [~,bg] = max(div_mo);
    [~,ed] = min(div_mo);
    burst_bg = bg + smslen +smslen/2;
    burstlen = ed - bg;
    end