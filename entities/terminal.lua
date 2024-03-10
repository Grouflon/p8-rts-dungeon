function terminal(_pos, _velocity)
  return {
    pos=_pos,
  }
end

function terminal_update(_e)
    for _a in all(agents) do
      
    end
end

function terminal_draw(_e)
  spr(6, _e.pos.x, _e.pos.y)
end