mine={}
mine.pos=vec2()
mine.pos.x=50
mine.pos.y=50
mine.radius=5
mine.timer=2
mine.time=0
mine.isactived=false

function mine_update()
  if (mine.isactived) then
    mine.time+=1/60
    if (mine.time>mine.timer) then
        mine.isactived=false
        mine.time=0
    end
  end

  for agent in all(agents) do
    if (vec2_len(agent.pos-mine.pos) < mine.radius) mine.isactived = true
  end
end

function mine_draw()
  if (mine.isactived)then
    pset(mine.pos.x, mine.pos.y,8)
      circfill(mine.pos.x, mine.pos.y,mine.radius,8)
    else
    pset(mine.pos.x, mine.pos.y,9)
  end
end