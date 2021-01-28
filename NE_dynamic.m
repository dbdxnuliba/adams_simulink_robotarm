function tau = NE_dynamic(theta, theta_d, theta_dd)
DH=[0,  0,  0.28,50;
    90, 0,  0.31,75;
    -90,0,  0.27,10;
    0,  1.9,0.27,125;
    0,  1.9,0.27,240;
    90, 0,  0.31,175;
    -90,0,  0.65,200];
% 初始化
w=zeros(3,8);
v=zeros(3,8);
wd=zeros(3,8);
vd=zeros(3,8);
vc=zeros(3,7);
F=zeros(3,7);
N=zeros(3,7);
f=zeros(3,8);
n=zeros(3,8);
tau=zeros(1,7);
% 各关节p及各link质心pc的距离
p=[[0,0,0.28];
   [0,-0.31,0];
   [0,0.27,0];
   [1.9,0,0.27];
   [1.9,0,0.27];
   [0,-0.31,0];
   [0,0.65,0]];
pc=[[0,0,0];
    [0,0,0.135];
    [0.95,0,0];
    [0.95,0,0];
    [0,-0.155,0];
    [0,0.325,0];
    [0,0,0.3]];
p=p';
pc=pc';
z = [0; 0; 1];
% 各连杆质量
m=[2.3,0.8,52,55,1.7,3.2,1.9];
% 惯性张量
I=cat(3,diag([0.045,0.062,0.0097]),...
   diag([0.058,0.058,0.0006]),...
   diag([16,16,0.057]),...
   diag([18,18,0.074]),...
   diag([0.016,0.016,0.00025]),...
   diag([0.12,0.12,0.00049]),...
   diag([0.018,0.018,0.00031]));
% 旋转矩阵
for i=1:7
    DH(i,4)=theta(i);
end
T=cat(3,MDHTrans(DH(1,1)*pi/180, DH(1,2), DH(1,3), DH(1,4)*pi/180),...
        MDHTrans(DH(2,1)*pi/180, DH(2,2), DH(2,3), DH(2,4)*pi/180),...
        MDHTrans(DH(3,1)*pi/180, DH(3,2), DH(3,3), DH(3,4)*pi/180),...
        MDHTrans(DH(4,1)*pi/180, DH(4,2), DH(4,3), DH(4,4)*pi/180),...
        MDHTrans(DH(5,1)*pi/180, DH(5,2), DH(5,3), DH(5,4)*pi/180),...
        MDHTrans(DH(6,1)*pi/180, DH(6,2), DH(6,3), DH(6,4)*pi/180),...
        MDHTrans(DH(7,1)*pi/180, DH(7,2), DH(7,3), DH(7,4)*pi/180));
R=cat(3,T(1:3,1:3,1),...
        T(1:3,1:3,2),...
        T(1:3,1:3,3),...
        T(1:3,1:3,4),...
        T(1:3,1:3,5),...
        T(1:3,1:3,6),...
        T(1:3,1:3,7));
Rt=cat(3,T(1:3,1:3,1)',...
        T(1:3,1:3,2)',...
        T(1:3,1:3,3)',...
        T(1:3,1:3,4)',...
        T(1:3,1:3,5)',...
        T(1:3,1:3,6)',...
        T(1:3,1:3,7)');
%% Outward iterations:
for i=1:7
    w(:,i+1)=Rt(:,:,i)*w(:,i)+theta_d(i)*z;
    wd(:,i+1)=Rt(:,:,i)*wd(:,i)+cross(Rt(:,:,i)*w(:,i),z*theta_d(i))+theta_dd(i)*z;
    vd(:,i+1)=Rt(:,:,i)*(cross(wd(:,i),p(:,i))+cross(w(:,i),cross(w(:,i),p(:,i)))+v(:,i));
    vc(:,i+1)=cross(wd(:,i+1),pc(:,i))+cross(w(:,i+1),cross(w(:,i+1),pc(:,i)))+vd(:,i+1);
    F(:,i)=m(i)*vc(:,i);
    N(:,i)=I(:,:,i)*wd(:,i+1)+cross(w(:,i+1),I(:,:,i)*w(:,i+1));
end  
%% Inward iterations: i:
for j=1:7
    i=8-j;
    f(:,i)=F(:,i)+R(:,:,i)*f(:,i+1);
    n(:,i)=N(:,i)+R(:,:,i)*n(:,i+1)+cross(p(:,i),R(:,:,i)*f(:,i+1));
    tau(i)=n(:,i)'*z;
end
end