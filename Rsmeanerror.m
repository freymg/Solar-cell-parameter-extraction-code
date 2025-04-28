function [Error_rs] = Rsmeanerror(I,Iref)
    fin=length(Iref);
    inicio=fin-5;
    j=1;
    aux2=0;
    for i=inicio:fin
        aux(j)=Iref(i)-I(i);
        j++;
    endfor
    for i=1:5
        aux2=aux2+aux(i);
    endfor
    Error_rs=aux2/5;
endfunction