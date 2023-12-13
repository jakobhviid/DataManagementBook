-- Code to change color borrowed and adapted from chickenize package
-- Code from https://tex.stackexchange.com/questions/21139/how-to-visualize-the-underfull-box-in-final-output-pdf-files

WHAT = node.id("whatsit")
COL = node.subtype("pdf_colorstack")
color_push = node.new(WHAT, COL)
color_pop = node.new(WHAT, COL)
color_push.stack = 0
color_pop.stack = 0
color_push.command = 1     -- replace command with cmd if using LuaTeX < 0.76.0
color_pop.command = 2      -- replace command with cmd if using LuaTeX < 0.76.0


function vertical_pack(h, grcode, tam, tipo, maxd)
  local g, b
  g, b = node.vpack(h, tam, tipo)
  if (b > 100) then
    color_push.data="0.79296875 0.09375 0.11328125 rg"
    h = node.insert_before(h, h, node.copy(color_push))
    h = node.insert_after(h, node.tail(h), node.copy(color_pop))
    return h
  end
  return true
end

-- Install filter into luatex callbacks
luatexbase.add_to_callback('vpack_filter', vertical_pack, 'vpack_filter')
