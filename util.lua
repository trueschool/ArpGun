function copy(obj)
  if type(obj) ~= 'table' then return obj end
  local res = {}
  for k, v in pairs(obj) do res[copy(k)] = copy(v) end
  return res
end

function generateEuclidean(pulses, steps, offset)
  local sequence = {}
  if pulses <= 0 or steps <= 0 then
    for i=1, steps do sequence[i] = 0 end
    return sequence
  end
  for i = 0, steps - 1 do
    if (i * pulses) % steps < pulses then
      table.insert(sequence, 1)
    else
      table.insert(sequence, 0)
    end
  end
  local shifted = {}
  offset = offset % steps
  for i = 1, steps do
    local idx = ((i - 1 - offset + steps) % steps) + 1
    table.insert(shifted, sequence[idx])
  end
  return shifted
end
