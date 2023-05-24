function [I,P,V] = corriente(Ip,Is1,Is2,nd1,nd2,Rp,Rs,Is,Voc,nc)
	
	V=0:(Voc/550):Voc;
	Vt=26e-3;
	i=length(V);
	
	for k=1:i
		if(k==1)
			I(k)=Ip-Is1*(exp((V(k)+(Rs*Is))/(Vt*nd1*nc))-1)-Is2*(exp((V(k)+(Rs*Is))/(Vt*nd2*nc))-1)-(V(k)+(Rs*Is))/Rp;
		else
			I(k)=Ip-Is1*(exp((V(k)+(Rs*I(k-1)))/(Vt*nd1*nc))-1)-Is2*(exp((V(k)+(Rs*I(k-1)))/(Vt*nd2*nc))-1)-(V(k)+(Rs*I(k-1)))/Rp;
		endif
		P(k)=V(k)*I(k);
	endfor
endfunction 