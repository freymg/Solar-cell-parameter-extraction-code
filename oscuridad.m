close all
clear all
clc

graphics_toolkit("qt");

%Rs=input("Resistencia serie ")
%Rsh=input("Resistencia paralelo ")
%Is1=input("Corriente saturacion diodo ideal ")
%Is2=input("Corriente saturacion diodo no ideal ")
%n1=input("Factor de idealidad diodo ideal ")
%n2=input("Factor de idealidad diodo no ideal ")
entrada=csvread('datos_ida.csv');
Rs=entrada(1);
Rsh=entrada(2);
Is1=entrada(3);
Is2=entrada(4);
n1=entrada(5);
n2=entrada(6);
flag_stop=input("Error de condicion de paro:   ")
clc
%numero de celdas conectadas en serie. modificar en caso de que se cuente con mas de 1 o un voltaje mayor al de la celda unitaria
nc=1;

punto=1;
err_eq=0;
print_datos=0;

cel=csvread('celda.csv');
Vcel=cel(:,1)';
Iref=abs(cel(:,2)');
Ix=Iref(1);
dis1=0.00001*Is1;
dis2=0.00001*Is2;
if Ix == 0
  cstop1=Is2;
else
  cstop1=abs(0.01*Ix);
endif

fi=length(Iref);
in=fi-5;
Imean_sup=0;
for k=in:fi
    Imean_sup=Imean_sup+Iref(k);
endfor
Imean_sup=Imean_sup/5;
cstop2=abs(0.1*Imean_sup);

##I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
##[Irl,Vrl]=extraccion(Iref,Vcel,Rsh,Rs);
##xm=mean(Vrl);
##ym=mean(Irl);
##sumxx=sum((Vrl-xm).^2);
##sumxy=sum((Vrl-xm).*(Irl-ym));
##pendiente=sumxy/sumxx;
##ordenada=ym-(pendiente*xm);
##n2=1.609e-19/(300*pendiente*1.38e-23);
##Is2=exp(ordenada);
##
##[Irl,Vrl]=extraccion2(Iref,Vcel,Rsh,Rs);
##xm=mean(Vrl);
##ym=mean(Irl);
##sumxx=sum((Vrl-xm).^2);
##sumxy=sum((Vrl-xm).*(Irl-ym));
##pendiente=sumxy/sumxx;
##ordenada=ym-(pendiente*xm);
##n1r=n1;
##n1=1.609e-19/(300*pendiente*1.38e-23);
##if n1 > 1.3
##  n1=n1r
##endif 


do
    [Irl,Vrl]=extraccion2(Iref,Vcel,Rsh,Rs);
    xm=mean(Vrl);
    ym=mean(Irl);
    sumxx=sum((Vrl-xm).^2);
    sumxy=sum((Vrl-xm).*(Irl-ym));
    pendiente=sumxy/sumxx;
    ordenada=ym-(pendiente*xm);
    n1r=n1;
    n1=1.609e-19/(300*pendiente*1.38e-23);
    if n1 > 1.3
      n1=n1r;
    endif
    
    I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
    %ajuste de parte negativa de grafica de corriente
    cond1=Ix-I(1);
    if(cond1 > 0)
        do
            Rsh--;
            %Is1=Is1+dis1;
            %Is2=Is2+dis2;
            I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
            err1=Ix-I(1);
            if(err1 < 0)
                break
            endif
        until(abs(err1) <= cstop1)
    elseif(cond1 < 0)
        do
            Rsh++;
            %Is1=Is1-dis1;
            %Is2=Is2-dis2;
            I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
            err1=Ix-I(1);
            if(err1 > 0)
                break
            endif
        until(abs(err1) <= cstop1)
    endif

    %ajuste para valores grandes de voltaje. Punto  de saturacion debido a RS
    rs_err=Rsmeanerror(I,Iref);
    if(rs_err > 0)
        do
            Rs=Rs-10e-3;
            %Is1=Is1+dis1;
            %Is2=Is2+dis2;
            I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
            rs_err=Rsmeanerror(I,Iref);
            if(rs_err < 0)
                break
            endif
        until(abs(rs_err) <= cstop2)
    elseif(rs_err < 0)
        do
            Rs=Rs+10e-3;
            %Is1=Is1-dis1;
            %Is2=Is2-dis2;
            I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
            rs_err=Rsmeanerror(I,Iref);
            if(rs_err > 0)
                break
            endif
        until(abs(rs_err) <= cstop2)
    endif

    %ajuste de curvatura en voltajes intermedios
    [Irl,Vrl]=extraccion(Iref,Vcel,Rsh,Rs);
    xm=mean(Vrl);
    ym=mean(Irl);
    sumxx=sum((Vrl-xm).^2);
    sumxy=sum((Vrl-xm).*(Irl-ym));
    pendiente=sumxy/sumxx;
    ordenada=ym-(pendiente*xm);
    n2r=n2;
    n2=1.609e-19/(300*pendiente*1.38e-23);
    if n2 > 2
        n2=n2r;
    endif
    
    %Is2=exp(ordenada);

    %[Irl,Vrl]=extraccion2(I,Vcel,Rsh,Rs);
    %xm=mean(Vrl);
    %ym=mean(Irl);
    %sumxx=sum((Vrl-xm).^2);
    %sumxy=sum((Vrl-xm).*(Irl-ym));
    %pendiente=sumxy/sumxx;
    %ordenada=ym-(pendiente*xm);
    %n1=1.609e-19/(300*pendiente*1.38e-23);

    I=blacki(Is1,Is2,n1,n2,Rsh,Rs,nc,Vcel,Ix);
    stopf=abs(mean(Iref-I));
    disp('error: '), disp(stopf)
    
    if punto > 3
        if stopf == v_er(punto-1)
            err_eq++;
        endif
        if stopf == v_er(punto-2)
            err_eq++;
        endif
        if stopf == v_er(punto-3)
            err_eq++;
        endif
    endif

    if err_eq >= 5
        disp("Intenta con un error mayor o igual a "),disp(min(v_er))
        print_datos=1;
        break
    endif

    v_er(punto)=stopf;
    punto++;

until(stopf <= flag_stop)

if print_datos == 0
    disp("Resistencia serie"),disp(Rs)
    disp("Resistencia paralelo"),disp(Rsh)
    disp("Corriente saturacion diodo ideal"),disp(Is1)
    disp("Corriente saturacion diodo no ideal"),disp(Is2)
    disp("Factor de idealidad diodo ideal"),disp(n1)
    disp("Factor de idealidad diodo no ideal"),disp(n2)
    datos=[Rs,Rsh,Is1,Is2,n1,n2];
    csvwrite('datos_return.csv', datos)
    semilogy(Vcel,Iref,Vcel,I)
endif