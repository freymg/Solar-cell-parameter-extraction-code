close all
clear all
clc
graphics_toolkit("qt");
%Voc=input("Voltaje de Circuito Abierto [V]:  ")
%Isc=input("Corriente de Corto Circuito [A]:  ")
%Vmp=input("Voltaje de maxima potencia [V]:  ")
%Imp=input("Corriente de maxima potencia [A]:  ")
entrada=csvread('entrada.csv');
Voc=entrada(1);
Isc=entrada(2);
Vmp=entrada(3);
Imp=entrada(4);
nc=input("Numero de celdas en serie que forman el panel:  ")
mxe=input("Error permitido para punto de maxima potencia:  ")
decision=input("Presiona 1 si es primera vez o 2 si es segunda o mas.  ")
clc


Imr=Imp;
Vmr=Vmp;

Rsh_min=abs(Vmp/(Imp-Isc));
Pmax_ref=Imp*Vmp;
Rs_max=abs((Voc-Vmp)/Imp);
Vt=26e-3;

if decision == 1
	Rp=Rsh_min;
	Rs=1e-3;
	n1=1;
	n2=1.3;
	Io1=Isc/(exp(Voc/(Vt*n1*nc))-1);
	Io2=Isc/(exp(Voc/(Vt*n2*nc))-1);
elseif decision == 2
	cel=csvread('datos_return.csv');
	Rp=cel(2);
	Rs=cel(1);
	n1=cel(5);
	n2=cel(6);
	Io1=cel(3);
	Io2=cel(4);
endif 

eri=1e-6;
tol=1e-4;
tol2=0.01*Vmp;
Ipv=(Rp+Rs)*Isc/Rp;

in1=0.01*Io1;
in2=0.01*Io2;
[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);
j=0;
flgp=1;
chk=0;
chkalg=0;
%figure

do
	vref=abs(min(P));
	[pa,ix]=max(P);
	Vmax=V(ix);
	if(Vmax < Vmp) %voltaje de maxP menor que experimental
		%disp("voltaje menor")
		do
			Rsr=Rs;
			Io1r=Io1;
			Io2r=Io2;
			Rs=Rs-1e-3;
			if(Rs < 0)
				Rs=Rs_max;
			endif
			Io1=Io1-in1;
			Io2=Io2-in2;
			Ipv=(Rp+Rs)*Isc/Rp;
			[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);	
			%plot(V,I);
			%refresh()
			[pa,ix]=max(P);
			va=min(P);
			if(abs(va) > (2*vref) && va < 0)
				Rs=Rsr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			Vmax=V(ix);
			if(Vmax > Vmr)
				Rs=Rsr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			err=abs(Vmr-Vmax);
		until(err <= tol2)
	elseif(Vmax > Vmp) %voltaje de maxP mayor que experimental
		%disp("voltaje mayor")
		do
			Rsr=Rs;
			Io1r=Io1;
			Io2r=Io2;
			Rs=Rs+1e-3;
			if(Rs >= Rs_max)
				Rs=1e-3;
			endif
			Io1=Io1+in1;
			Io2=Io2+in2;
			Ipv=(Rp+Rs)*Isc/Rp;
			[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);	
			%plot(V,I);
			%refresh()
			[pa,ix]=max(P);
			va=min(P);
			if(abs(va) > (2*vref) && va < 0)
				Rs=Rsr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			Vmax=V(ix);
			if(Vmax < Vmr)
				Rs=Rsr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			err=abs(Vmr-Vmax);
		until(err <= tol2)
	endif
	
	vref=abs(min(P));
	[pa,ix]=max(P);
	Imax=I(ix);
	if(Imax < Imp) %corriente de maxP menor que experimiental
		%disp("corriente menor")
		do
			Rpr=Rp;
			Io1r=Io1;
			Io2r=Io2;
			Rp++;
			Io1=Io1-in1;
			Io2=Io2-in2;
			Ipv=(Rp+Rs)*Isc/Rp;
			[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);
			%plot(V,I);
			%refresh()
			[pa,ix]=max(P);
			Imax=I(ix);
			if(Imax > Imr)
				Rp=Rpr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			va=min(P);
			if(abs(va) > (2*vref) && va < 0)
				Rp=Rpr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			err=abs(Imr-Imax);
		until(err <= tol)
	elseif(Imax > Imp) %corriente de maxP mayor que experimiental
		%disp("corriente mayor")
		do
			Rpr=Rp;
			Io1r=Io1;
			Io2r=Io2;
			Rp--;
			if(Rp < Rsh_min)
				Rp=Rsh_min;
			endif
			Io1=Io1+in1;
			Io2=Io2+in2;
			Ipv=(Rp+Rs)*Isc/Rp;
			[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);
			%plot(V,I);
			%refresh()
			[pa,ix]=max(P);
			Imax=I(ix);
			if(Imax < Imr)
				Rp=Rpr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			va=min(P);
			if(abs(va) > (2*vref) && va < 0)
				Rp=Rpr;
				Io1=Io1r;
				Io2=Io2r;
				break
			endif
			err=abs(Imr-Imax);
		until(err <= tol)
	endif
	
	vref=abs(min(P));
	l=length(I);
	%flg=abs(I(l));
	if(I(l) < 0) %final de grafica I-V menor que 0
		%disp("I-V menor")
		do
			Io1r=Io1;
			Io2r=Io2;
			Rpr=Rp;
			n1r=n1;
			n2r=n2;
			n1=n1+1e-3;
			if(n1 > 1.3)
				n1=1;
			endif
			n2=n2+1e-3;
			if(n2 > 2)
				n2=1.3;
			endif
			Rp++;
			Io1=Io1-in1;
			Io2=Io2-in2;
			Ipv=(Rp+Rs)*Isc/Rp;
			[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);
			%plot(V,I);
			%refresh()
			l=length(I);
			[pa,ix]=max(P);
			va=min(P);
			if(abs(va) > (2*vref) && va < 0)
				Rp=Rpr;
				Io1=Io1r;
				Io2=Io2r;
				n1=n1r;
				n2=n2r;
				break
			endif
		until(I(l) > 0)
	elseif(I(l) > 0) %final de grafica I-V mayor que 0
		%disp("I-V mayor")
		do
			Io1r=Io1;
			Io2r=Io2;
			Rpr=Rp;
			n1r=n1;
			n2r=n2;
			n1=n1-1e-3;
			if(n1 < 1)
				n1=1.3;
			endif
			n2=n2-1e-3;
			if(n2 < 1.3)
				n2=2;
			endif
			Rp--;
			if(Rp < Rsh_min)
				Rp=Rsh_min;
			endif
			Io1=Io1+in1;
			Io2=Io2+in2;
			Ipv=(Rp+Rs)*Isc/Rp;
			[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);
			%plot(V,I);
			%refresh()
			l=length(I);
			[pa,ix]=max(P);
			va=min(P);
			if(abs(va) > (2*vref) && va < 0)
				Rp=Rpr;
				Io1=Io1r;
				Io2=Io2r;
				n1=n1r;
				n2=n2r;
				break
			endif
		until(I(l) < 0)
	endif
	
	[pa,ix]=max(P);
	flgpr=flgp;
	flgp=abs(Pmax_ref-pa);
	error=flgp
	if(flgp == Inf)
		disp("llegue")
		Rp=Rsh_min;
		Io1=Isc/(exp(Voc/(Vt*n1*nc))-1);
		Io2=Isc/(exp(Voc/(Vt*n2*nc))-1);
		n1=n1r;
		n2=n2r;
		[I,P,V]=corriente(Ipv,Io1,Io2,n1,n2,Rp,Rs,Isc,Voc,nc);
	endif
	if(flgp > (1.2*flgpr) && j > 0 && Rp ~= Rpr)
		disp("Problema en convergencia, porfavor intenta con un error minimo de")
		disp(min(erx))
		chk++;
		break
	endif
	if(flgp == flgpr && j > 0 && Rp ~= Rpr)
		chkalg++;
		if(chkalg == 10)
			break
		endif
	endif
	j++;
	erx(j)=flgp;
until(flgp <= mxe)

if(chk == 0)
	disp("Resistencia serie"),disp(Rs)
	disp("Resistencia paralelo"),disp(Rp)
	disp("Corriente saturacion diodo ideal"),disp(Io1)
	disp("Corriente saturacion diodo no ideal"),disp(Io2)
	disp("Factor de idealidad diodo ideal"),disp(n1)
	disp("Factor de idealidad diodo no ideal"),disp(n2)
	disp("Corriente de fotogeneracion"),disp(Ipv)
	disp("Error de aproximacion en mpp"),disp(erx(j))
	disp("Numero de iteraciones"),disp(j)
	[pa,ix]=max(P);
	disp("Voltaje de maxima potencia"),disp(V(ix))
	disp("Corriente de maxima potencia"),disp(I(ix))
	figure
	plot(V,I)
	grid
	figure
	plot(V,P)
	grid
	datos=[Rs,Rp,Io1,Io2,n1,n2];
	csvwrite('datos_ida.csv', datos)
endif
