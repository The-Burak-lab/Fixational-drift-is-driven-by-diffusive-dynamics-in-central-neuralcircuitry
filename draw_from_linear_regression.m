function [y, x] = draw_from_linear_regression(slope, intercept, corrCoeff, x_range, N)
% Given a linear regression result, draw random initiations
% of the dependent variable
% Parameres:
% slope - float, the slope of the regression line
% intercept - float, the intercept of the regression line
% corrCoeff - float, the dispression of the random numbers
% x_range - 1 X 2 float vector, the range of the dependent variable, from
%           which we will uniformly sample
% N -       int. # of random intiaitions to generate
%-------------------------------------------------
% VarX = diff(x_range)^2/12; % assuming we uniformly sample from X

if nargin ~= 5
    VarX = var(x_range);
    VarY = slope^2 * VarX * (1 / corrCoeff^2 - 1);
    y = intercept + normrnd(slope*x_range, VarY^0.5);
    x = x_range;
else
    if length(x_range) == 2
        x = x_range(1) + diff(x_range) * rand(N, 1);
    else
        x = x_range;
    end
    VarX = var(x);
    VarY = slope^2 * VarX * (1 / corrCoeff^2 - 1);
    y = intercept + normrnd(slope*x, VarY^0.5);
end

end
