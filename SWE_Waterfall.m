clf;
clear all;
% define the grid size
n = 80;
dt = 0.003;
dx = 1;
dy = 1;
g = 9.8;
pi = 3.14;

U = ones(n+2,n+2); % displacement matrix 
F = zeros(n+2,n+2); % x Velocity
G = zeros(n+2,n+2); % y Velocity
% draw the mesh
grid = surf(U);
axis([1 n 1 n 0 5]);
hold all;

% addition code here - waterfall
K = zeros(n+2,n+2);
for i = 1:30
   K(:,i) = K(:,i) + 3 - (1/300)*i^2;
end
for i = 1:n
   Z = sin(i*pi/10)/i;
   U(:,i) = U(:,i) + Z;
end
% end addition code - waterfall

% create initial displacement
%[x,y] = meshgrid( linspace(-3,3,30) );
%a=-3:0.2:3;
%b=-3:0.2:3;
%[x,y]=meshgrid(a,b);
%R = sqrt(x.^2 + y.^2) + eps;
%Z = (sin(R)./R);
%Z = max(Z,0);
% add displacement to the height matrix
%w = size(Z,1);
%i = 1:w;
%j = 1:w;
%c = 30:w+29;
%d = 30:w+29;
%U(i,j) = U(i,j) + Z;
%U(c,d) = max(U(c,d),Z+1);

% empty matrix for half-step calculations
Ux = zeros(n+1,n+1);
Uy = zeros(n+1,n+1);
Fx = zeros(n+1,n+1);
Fy = zeros(n+1,n+1);
Gx = zeros(n+1,n+1);
Gy = zeros(n+1,n+1);

while 1==1
 U(:,:) = U(:,:) + K(:,:);
 % redraw the mesh
 set(grid, 'zdata', U);
 drawnow
 shading interp
 U(:,:) = U(:,:) - K(:,:);
 % blending the edges keeps the function stable
 %U(:,1) = U(:,2);
 %U(:,n+2) = U(:,n+1);
 U(1,:) = U(2,:);
 U(n+2,:) = U(n+1,:);

 % reverse direction at the x edges
 %F(1,:) = -F(2,:);
 %F(n+2,:) = -F(n+1,:);

 % reverse direction at the y edges
 G(:,1) = -G(:,2);
 G(:,n+2) = -G(:,n+1);


 % First half step
 i = 1:n+1;
 j = 1:n+1;

 % height
 Ux(i,j) = (U(i+1,j+1)+U(i,j+1))/2 - dt/(2*dx)*(F(i+1,j+1)-F(i,j+1));
 Uy(i,j) = (U(i+1,j+1)+U(i+1,j))/2 - dt/(2*dy)*(G(i+1,j+1)-G(i+1,j));

 % x momentum

 Fx(i,j) = (F(i+1,j+1)+F(i,j+1))/2 - ...
 dt/(2*dx)*( F(i+1,j+1).^2./U(i+1,j+1) - F(i,j+1).^2./U(i,j+1) + ...
 g/2*U(i+1,j+1).^2 - g/2*U(i,j+1).^2 ...
 );

 Fy(i,j) = (F(i+1,j+1)+F(i+1,j))/2 - ...
 dt/(2*dy)*( (G(i+1,j+1).*F(i+1,j+1)./U(i+1,j+1)) - (G(i+1,j).*F(i+1,j)./U(i+1,j)) );

 % y momentum
 Gx(i,j) = (G(i+1,j+1)+G(i,j+1))/2 - ...
 dt/(2*dx)*((F(i+1,j+1).*G(i+1,j+1)./U(i+1,j+1)) - ...
 (F(i,j+1).*G(i,j+1)./U(i,j+1)));

 Gy(i,j) = (G(i+1,j+1)+G(i+1,j))/2 - ...
 dt/(2*dy)*((G(i+1,j+1).^2./U(i+1,j+1) + g/2*U(i+1,j+1).^2) - ...
 (G(i+1,j).^2./U(i+1,j) + g/2*U(i+1,j).^2));

 % Second half step
 i = 2:n+1;
 j = 2:n+1;

 % height
 U(i,j) = U(i,j) - (dt/dx)*(Fx(i,j-1)-Fx(i-1,j-1)) - ...
 (dt/dy)*(Gy(i-1,j)-Gy(i-1,j-1));
 % x momentum
 F(i,j) = F(i,j) - (dt/dx)*((Fx(i,j-1).^2./Ux(i,j-1) + g/2*Ux(i,j-1).^2) - ...
 (Fx(i-1,j-1).^2./Ux(i-1,j-1) + g/2*Ux(i-1,j-1).^2)) ...
 - (dt/dy)*((Gy(i-1,j).*Fy(i-1,j)./Uy(i-1,j)) - ...
 (Gy(i-1,j-1).*Fy(i-1,j-1)./Uy(i-1,j-1)));
 % y momentum
 G(i,j) = G(i,j) - (dt/dx)*((Fx(i,j-1).*Gx(i,j-1)./Ux(i,j-1)) - ...
 (Fx(i-1,j-1).*Gx(i-1,j-1)./Ux(i-1,j-1))) ...
 - (dt/dy)*((Gy(i-1,j).^2./Uy(i-1,j) + g/2*Uy(i-1,j).^2) - ...
 (Gy(i-1,j-1).^2./Uy(i-1,j-1) + g/2*Uy(i-1,j-1).^2));

end
