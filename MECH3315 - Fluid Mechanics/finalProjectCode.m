clc;
clear all;
load('data_mod2_tsr70.mat')
D = 126; %diamter
R = D/2;
Re = 7.3*10^7; %reynolds number
Rho = 1.225; %density
Mu = 1.785*10^-5; %viscosity of air
velocity = Re*Mu/Rho/D %velocity profile 
TSR = 7; %tip speed ration
Omega = TSR*velocity/R; %angular velocity 
figure 
utmpx(:,:)=u(:,:,n3/2);
contourf(xx,yy,utmpx',100, 'linestyle','none')
daspect([1,1,1])
figure 
[~,ind]=min(abs(xx-3));
utmpz(:,:)=u(ind,:,:);
contourf(zz,yy,utmpz,80, 'linestyle','none')
daspect([1,1,1])
%flux  going through the faces
%we use the conservation of mass equation to 
%to calculate and plot the streamlines of the fluid
%for we create a nested loop that approximates  the flux going 
%throught the faces on each direction 
f1=0;
f2=0;
for j=1: n2-1
    for k=1:n3-1
        da=(yy(j+1)-yy(j))*(zz(k+1)-zz(k));
        f1=f1+u(1,j,k)*da;
        f2=f2+u(n1,j,k)*da;
    end 
end
f3=0;
f4=0;
for i=1:n1-1
    for j=1:n2-1
        da=(yy(j+1)-yy(j))*(xx(i+1)-xx(i));
        f3=f3+w(i,j,1)*da;
        f4=f4+w(i,j,n3)*da;
    end
end
f5=0;
f6=0;
for i=1:n1-1
    for k=1:n3-1
        da=(xx(i+1)-xx(i))*(zz(k+1)-zz(k));
        f5=f5+v(i,n2,k)*da;
        f6=f6+v(i,1,k)*da;
    end
end
total_flux=-f1+f2+f3-f4+f5-f6
%%verification of conservation of momentum
%The rate of x momentum influx to the control volume through yz plane 
%is equal to Rho u^2 times dy dz which is perpendicular to the yz plane 
%here we denote it as da
%we utilize a loop to calculate the summation from 1 to 256 in the yz plane
%then do the same for the xy and xz planes 
f1=0;
f2=0;
p1=0;
p2=0;
f1=0;
f2=0;
for j=1: n2-1
    for k=1:n3-1
        da=(yy(j+1)-yy(j))*(zz(k+1)-zz(k));
        f1=f1+u(1,j,k)^2*da;
        f2=f2+u(n1,j,k)^2*da;
        p1=p1+pr(1,j,k)*da;
        p2=p2+pr(n1,j,k)*da;
    end 
end
f3=0;
f4=0;
for i=1:n1-1
    for j=1:n2-1
        da=(yy(j+1)-yy(j))*(xx(i+1)-xx(i));
        f3=f3+u(i,j,1)*w(i,j,1)*da;
        f4=f4+u(i,j,n3)*w(i,j,n3)*da;
    end
end
f5=0;
f6=0;
for i=1:n1-1
    for k=1:n3-1
        da=(xx(i+1)-xx(i))*(zz(k+1)-zz(k));
        f5=f5+u(i,n2,k)*v(i,n2,k)*da;
        f6=f6+u(i,1,k)*v(i,1,k)*da;
    end
end
trust_coefficient =(8/pi)*(-f1+f2+f3-f4+f5-f6)+(p1-p2)*(4/pi)
%Thrust Force 
TF = .5*trust_coefficient*Rho*velocity^2*pi*63^2

% Power extracted by the wind turbine
%to calculate the power 
power_1=0;
power_2=0;
istart=75;
iend=127;
for j=1:n2-1
    for k=1:n3-1
        da=(zz(k+1)-zz(k))*(yy(j+1)-yy(j));
        tke1=(u(istart,j,k)^2.0+v(istart,j,k)^2.0+w(istart,j,k)^2.0)/2;
        tke2=(u(iend,j,k)^2.0+v(iend,j,k)^2.0+w(iend,j,k)^2.0)/2;
        power_1=power_1+((-u(istart,j,k)))*((tke1)+pr(istart,j,k))*da;
        power_2=power_2+(u(iend,j,k))*((tke2)+pr(iend,j,k))*da;
   end
end
power_3=0;
power_4=0;
for i=1:n1-1
    for j=1:n2-1
        da=(yy(j+1)-yy(j))*(xx(i+1)-xx(i));
        tke3=(u(i,j,istart)^2.0+v(i,j,istart)^2.0+w(i,j,istart)^2.0)/2;
        tke4=(u(i,j,iend)^2.0+v(i,j,iend)^2.0+w(i,j,iend)^2.0)/2;
        power_3=power_3+((-w(i,j,1)))*((tke3)+pr(i,j,1))*da;
        power_4=power_4+(w(i,j,n3))*((tke4)+pr(i,j,n3))*da;
    end
end
power_5=0;
power_6=0;
for i=1:n1-1
    for k=1:n3-1
        da=(xx(i+1)-xx(i))*(zz(k+1)-zz(k));
        tke5=(u(i,istart,k)^2.0+v(i,istart,k)^2.0+w(i,istart,k)^2.0)/2;
        tke6=(u(i,iend,k)^2.0+v(i,iend,k)^2.0+w(i,iend,k)^2.0)/2;
        power_5=power_5+((-v(i,iend,k)))*((tke3)+pr(i,iend,1))*da;
        power_6=power_6+(v(i,n3,k))*((tke4)+pr(i,iend,k))*da;
    end
end
WT_power_1=4/3.14*(power_1+power_2)*2;
WT_power_2=power_3+power_4;
WT_power_3=power_5+power_6;
c_p = -(WT_power_1+WT_power_2+WT_power_3)
power = 1/2*Rho*velocity^3*pi*R^2*c_p
%For visualisationn purpose Z and Y are transposed 
figure 
hold on
[X,Y,Z]=meshgrid(xx,zz,yy);
U=permute(u,[3,1,2]);
W=permute(v,[3,1,2]);
V=permute(w,[3,1,2]);

%Particles lines from 0
[sx,sy,sz]=meshgrid(0,linspace(1.25,1.75,5),linspace(.4,.8,5));
h=streamline(X,Y,Z,U,V,W,sx,sy,sz);
set(h,'color','green');
daspect([1,1,1])
axis([min(xx),max(xx),min(zz),max(zz),min(yy),max(yy)])
z0=1.5;y0=.7031;
theta=0:.1:2*pi;
zc=.5*cos(theta)+z0;
yc=.5*sin(theta)+y0;
fill3(ones(1,length(zc))*3,zc,yc,[.6,.6,.6])
grid on
view(3)
xlabel('x side view of turbine')
ylabel('y flow inlet')
zlabel('z')
       
% for visualization Z and Y are transposed 
figure 
hold on
[X,Y,Z]=meshgrid(xx,zz,yy);
U=permute(u,[3,1,2]);
W=permute(v,[3,1,2]);
V=permute(w,[3,1,2]);

%particles lines released from rotor plane 
[sx,sy,sz]=meshgrid(3,linspace(1.25,1.75,5),linspace(.4,.8,5));
h=streamline(X,Y,Z,U,V,W,sx,sy,sz);
set(h,'color','red');
daspect([1,1,1]);
axis([min(xx),max(xx),min(zz),max(zz),min(yy),max(yy)]);
z0=1.5;y0=.7031;
theta=0:.1:2*pi;
zc=.5*cos(theta)+z0;
yc=.5*sin(theta)+y0;
fill3(ones(1,length(zc))*3,zc,yc,[.6,.6,.6]);
grid on;
view(3);
xlabel('x side view of turbine');
ylabel('y flow inlet');
zlabel('z');

%Pressure plot
figure 
pr_vsec(:,:)=pr(:,30,:);
contourf(xx,zz,pr_vsec',250,'linestyle',' none');
daspect([1,1,1]);
xlabel('x side of wind turbine');
ylabel(' y inlet');
colorbar('Ticks',[-.3, .1],'Ticklabels',{'low pressure','high velocity/high pressure'});
