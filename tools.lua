-- log
__log={}
function log(_str)
  add(__log,_str)
end
function draw_log()
  color(7)
  cursor()
  foreach(__log, print)
  __log={}
end

-- math
function lerp(_a,_b,_t)
  return _a+(_b-_a)*_t
end
function clamp01(_v)
  return mid(_v,0,1)
end
function is_zero(_v, _threshold)
  _threshold = _threshold or 0.0001
  return abs(_v) < _threshold
end
local _base_is_zero = is_zero
function equals(_a,_b,_threshold)
  return is_zero(_a-_b,_threshold)
end

-- vec2
vec2_mt = {}
vec2_mt.__index = vec2_mt

function vec2_mt:__add(_v)
  return vec2(self.x + _v.x, self.y + _v.y)
end

function vec2_mt:__sub(_v)
  return vec2(self.x - _v.x, self.y - _v.y)
end

function vec2_mt:__mul(_s)
  return vec2(self.x * _s, self.y * _s)
end

function vec2_mt:__unm(_s)
  return vec2(-self.x, -self.y)
end

function vec2_mt:__tostring()
  return "{"..self.x..","..self.y.."}"
end

function vec2_mt:set(_x, _y)
  self.x = _x
  self.y = _y
end

function is_vec2(_o)
  return getmetatable(_o) == vec2_mt
end

function vec2(_x, _y)
-- Can build vec2 with another vec2
if (is_vec2(_x)) then
  _y = _x.y
  _x = _x.x
end

local _v = {
  x = _x or 0,
  y = _y or 0
}
setmetatable(_v, vec2_mt)
return _v
end

function vec2_dot(_v1, _v2)
  return _v1.x * _v2.x + _v1.y * _v2.y
end

function vec2_sqrlen(_v)
  return _v.x * _v.x + _v.y * _v.y
end

function vec2_len(_v)
  return sqrt(vec2_sqrlen(_v))
end

function vec2_normalized(_v)
  local _len = vec2_len(_v)
  if _len > 0.0 then
    return vec2(_v.x / _len, _v.y / _len)
  else
    return vec2()
  end
end

function vec2_flr(_v)
  return vec2(flr(_v.x), flr(_v.y))
end

is_zero=function(_v, _threshold)
  if (is_vec2(_v)) then
    return (_base_is_zero(_v.x, _threshold) and _base_is_zero(_v.y, _threshold))
  else
    return _base_is_zero(_v, _threshold)
  end
end
function vec2_is_zero(_v, _threshold)
  _threshold = _threshold or 0.01
  return abs(_v.x) <= _threshold and abs(_v.y) <= _threshold
end

function vec2_lerp(_a, _b, _t)
  return vec2(
    lerp(_a.x, _b.x, _t),
    lerp(_a.y, _b.y, _t)
    )
end

-- collision
col_aabb_aabb=function(_a,_b)
  return not(
    _a[1]>_b[3] or
    _a[3]<_b[1] or
    _a[2]>_b[4] or
    _a[4]<_b[2]
    )
end

--random
function rnd_range(_min,_max)
  return _min+rnd(_max-_min)
end

function rnd_screenpos(_margin)
  return vec2(
    rnd_range(_margin,128-_margin),
    rnd_range(_margin,128-_margin)
    )
end

-- table
function swap(_t,_a,_b)
  assert(_t[_a]~=nil and _t[_b]~=nil)
  local _temp=_t[_b]
  _t[_b]=_t[_a]
  _t[_a]=_temp
end

function sort(_t,_f)
  _f = _f or function(_a, _b)
    if (_a<_b) return -1
    if (_a>_b) return 1
    return 0
  end
  local _len=#_t
  for _i=2,_len do
    for _j=_i,2,-1 do
      if (_f(_t[_j],_t[_j-1]) < 0) then
        swap(_t,_j,_j-1)
      else
        break
      end
    end
  end
end

function contains(_t,_o)
  for _i=1,#_t do
    if (_t[_i]==_o) return true
  end
  return false
end