function [I] = blacki(Is1,Is2,nd1,nd2,Rp,Rs,nc,V,I1)
	
	Vt=26e-3;
	i=length(V);
	Is=I1;
	
	for k=1:i
		if(k==1)
			I(k)=Is1*(exp((V(k)-(Rs*Is))/(Vt*nd1*nc))-1)+Is2*(exp((V(k)-(Rs*Is))/(Vt*nd2*nc))-1)+(V(k)-(Rs*Is))/Rp;
		else
			I(k)=Is1*(exp((V(k)-(Rs*I(k-1)))/(Vt*nd1*nc))-1)+Is2*(exp((V(k)-(Rs*I(k-1)))/(Vt*nd2*nc))-1)+(V(k)-(Rs*I(k-1)))/Rp;
		endif
	endfor
	I=abs(I);
endfunction 