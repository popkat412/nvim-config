-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Remap :wqa to my custom :Wqa which tries to politley exit any open terminals
vim.cmd [[
  cnoreabbrev <expr> wqa  ((getcmdtype() == ':' && getcmdline() ==# 'wqa')  ? 'Wqa'  : 'wqa')
  cnoreabbrev <expr> wqa! ((getcmdtype() == ':' && getcmdline() ==# 'wqa!') ? 'Wqa!' : 'wqa!')
]]
