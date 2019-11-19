--[[
    A set of functions that perform 'easing'

    Basically, with a given input value, an output value
    will be generated.

    t - current time
    b - start value
    c - change in value
    d - duration

    t, and d could be absolute times, or frames.  The main thing is they
    are expressed in the same units so they can be used to calculate a fraction
    of 'doneness'

    This is very similar to using map(x, low, high, nlow, nhigh)
    But, the function isn't strictly linear.

    References: 
    https://easings.net/en
    http://gizma.com/easing/
    older broken link
    http://www.robertpenner.com

]]

-- local access to some math stuff
local PI = math.pi;
local pow = math.pow;
local sqrt = math.sqrt;
local sin = math.sin;
local cos = math.cos;


local easing = {}

easing.easeLinear = function (t, b, c, d) 
	return c*t/d + b;
end;

easing.easeInQuad = function (t, b, c, d) 
	t = t / d;
	return c*t*t + b;
end

easing.easeOutQuad = function (t, b, c, d)
	t = t / d;
	return -c * t*(t-2) + b;
end

easing.easeInOutQuad = function (t, b, c, d)
	t = t / d/2;
    if (t < 1) then
        return c/2*t*t + b;
    end

    t = t - 1;
	return -c/2 * (t*(t-2) - 1) + b;
end

easing.easeInCubic = function (t, b, c, d)
	t = t / d;
	return c*t*t*t + b;
end

easing.easeOutCubic = function (t, b, c, d)
    t = t / d;
    t = t - 1;

	return c*(t*t*t + 1) + b;
end

easing.easeInOutCubic = function (t, b, c, d)
	t = t / d/2;
    if (t < 1) then
        return c/2*t*t*t + b;
    end

    t = t - 2;
    
	return c/2*(t*t*t + 2) + b;
end

easing.easeInQuart = function (t, b, c, d)
	t = t / d;
	return c*t*t*t*t + b;
end

easing.easeOutQuart = function (t, b, c, d)
    t = t / d;
    t = t - 1;

	return -c * (t*t*t*t - 1) + b;
end

easing.easeInOutQuart = function (t, b, c, d)
	t = t / d/2;
    if (t < 1) then
        return c/2*t*t*t*t + b;
    end

	t = t - 2;
	return -c/2 * (t*t*t*t - 2) + b;
end

easing.easeInQuint = function (t, b, c, d)
    t = t / d;
    
	return c*t*t*t*t*t + b;
end

easing.easeOutQuint = function (t, b, c, d)
    t = t / d;
    t = t - 1;

	return c*(t*t*t*t*t + 1) + b;
end

easing.easeInOutQuint = function (t, b, c, d)
	t = t / d/2;
    if (t < 1) then 
        return c/2*t*t*t*t*t + b;
    end

    t = t - 2;
    
	return c/2*(t*t*t*t*t + 2) + b;
end

easing.easeInSine = function (t, b, c, d)
	return -c * cos(t/d * (PI/2)) + c + b;
end

easing.easeOutSine = function (t, b, c, d) 
	return c * sin(t/d * (PI/2)) + b;
end

easing.easeInOutSine = function (t, b, c, d)
	return -c/2 * (cos(PI*t/d) - 1) + b;
end

easing.easeInExpo = function (t, b, c, d)
	return c * pow( 2, 10 * (t/d - 1) ) + b;
end

easing.easeOutExpo = function (t, b, c, d)
	return c * ( -pow( 2, -10 * t/d ) + 1 ) + b;
end

easing.easeInOutExpo = function (t, b, c, d)
	t = t / d/2;
    if (t < 1) then
        return c/2 * pow( 2, 10 * (t - 1) ) + b;
    end

    t = t - 1;

	return c/2 * ( -pow( 2, -10 * t) + 2 ) + b;
end

easing.easeInCirc = function (t, b, c, d)
	t = t / d;
	return -c * (sqrt(1 - t*t) - 1) + b;
end

easing.easeOutCirc = function (t, b, c, d)
	t = t / d;
	t = t - 1;
	return c * sqrt(1 - t*t) + b;
end

easing.easeInOutCirc = function (t, b, c, d)
	t = t / d/2;
    if (t < 1) then
        return -c/2 * (sqrt(1 - t*t) - 1) + b;
    end

	t = t - 2;
	return c/2 * (sqrt(1 - t*t) + 1) + b;
end

return easing