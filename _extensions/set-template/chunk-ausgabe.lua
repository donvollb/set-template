-- Entfernt die Hülle, die Quarto um jede Chunk-Ausgabe legt (in Typst ein #block[...]).
-- Sonst sind Seitenumbrüche ({{< pagebreak >}}) in Chunks nicht möglich, weil Typst
-- #pagebreak() innerhalb eines Blocks nicht erlaubt.

function Div(el)
  if el.classes:includes("cell") then
    return el.content
  end
end
