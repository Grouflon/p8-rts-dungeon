snakes={}
function snake(_pos)
  local _e = entity(_pos)
  _e.target=nil
  _e.target_pos=vec2()

  _e.added = function(_snake)
    add(snakes, _snake)
  end

  _e.removed = function(_snake)
    del(snakes, _snake)
  end
  _e.actions={}

  _e.update = function(_snake)
    if (_snake.target == nil) then
     printh("here")
      for _a in all(agents) do
        if (vec2_len(_a.pos-_snake.pos) < 500) then
          _snake.target=_a
          local path = find_path(level, _snake.pos, _a.pos)
          agent_follow_path(_snake, path, 0.2)
          break
        end
      end
    elseif (_snake.target_pos != _snake.target.pos) then

      printh(count(actions)..  "--" ..count(_snake.actions).. "--")
      _snake.target_pos = _snake.target.pos
      agent_stop_actions(_snake)
      local path = find_path(level, _snake.pos, _snake.target.pos)
      agent_follow_path(_snake, path, 0.2)
    elseif (_snake.target_pos == _snake.pos) then
--      printh("end")
      agent_stop_actions(_snake)

      _snake.target=nil
    end
  end

  _e.draw = function(_snake)
    pset(_snake.pos.x, _snake.pos.y, 1)
  end
  return _e
end

function agent_stop_actions2(_a)
  for i=#_a.actions,1,-1 do
    action_stop2(_a.actions[i])
  end
end

function action_stop2(_act)
  if (not _act) return
  _act.definition.stop(_act)
  foreach(_act.agents,function(_a) del(_a.actions,_act) end)
  del(actions,_act)
  _act.alive=false
end