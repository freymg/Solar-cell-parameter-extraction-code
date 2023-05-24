function [lni,vni] = extraccion(I,V,Rp,Rs)
    h=length(V);
    l=1;
    for i=1:h
        if V(i) > 0
            lni(l)=log(abs(I(i)-((V(i)-(I(i)*Rs))/Rp)));
            vni(l)=V(i);
            l++;
        endif
    endfor
endfunction