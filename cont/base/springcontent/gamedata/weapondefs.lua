--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  file:    weapondefs.lua
--  brief:   weapondef parser
--  author:  Dave Rodgers
--
--  Copyright (C) 2007.
--  Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local weaponDefs = {}

local shared = {} -- shared amongst the lua weapondef environments

local preProcFile  = 'gamedata/weapondefs_pre.lua'
local postProcFile = 'gamedata/weapondefs_post.lua'

local TDF = TDFparser or VFS.Include('gamedata/parse_tdf.lua')

local system = VFS.Include('gamedata/system.lua')
VFS.Include('gamedata/VFSUtils.lua') -- for legacy code that might need its contents

local section = 'weapondefs.lua'

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Run a pre-processing script if one exists
--

if (VFS.FileExists(preProcFile)) then
  Shared = shared  -- make it global
  WeaponDefs = weaponDefs  -- make it global
  VFS.Include(preProcFile)
  WeaponDefs = nil
  Shared = nil
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Load the TDF weapondef files
--

local tdfFiles = VFS.DirList('weapons/', '*.tdf', nil, true)

for _, filename in ipairs(tdfFiles) do
  local wds, err = TDF.Parse(filename)
  if (wds == nil) then
    Spring.Log(section, 'Error parsing ' .. filename .. ': ' .. err)
  else
    for name, wd in pairs(wds) do
      weaponDefs[name] = wd
    end
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Load the raw LUA format weapondef files
--  (these will override the TDF versions)
--

local luaFiles = VFS.DirList('weapons/', '*.lua', nil, true)

for _, filename in ipairs(luaFiles) do
  local wdEnv = {}
  wdEnv._G = wdEnv
  wdEnv.Shared = shared
  wdEnv.GetFilename = function() return filename end
  setmetatable(wdEnv, { __index = system })
  local success, wds = pcall(VFS.Include, filename, wdEnv)
  if (not success) then
    Spring.Log(section, LOG.ERROR, 'Error parsing ' .. filename .. ': ' .. tostring(wds))
  elseif (wds == nil) then
    Spring.Log(section, LOG.ERROR, 'Missing return table from: ' .. filename)
  else
    for wdName, wd in pairs(wds) do
      if ((type(wdName) == 'string') and (type(wd) == 'table')) then
        weaponDefs[wdName] = wd
      end
    end
  end  
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Run a post-processing script if one exists
--

if (VFS.FileExists(postProcFile)) then
  Shared = shared  -- make it global
  WeaponDefs = weaponDefs  -- make it global
  VFS.Include(postProcFile)
  WeaponDefs = nil
  Shared = nil
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--  Basic checks to remove invalid weapons
--

for name, def in pairs(weaponDefs) do
  local model = def.model
  if ((type(model) == 'string') and (#model > 0)) then
    local modelFile = 'objects3d/' .. model
    if ((not VFS.FileExists(modelFile))           and
        (not VFS.FileExists(modelFile .. '.3do')) and
        (not VFS.FileExists(modelFile .. '.s3o'))) then
      weaponDefs[name] = nil
      Spring.Log(section, LOG.ERROR, 'removed ' .. name .. ' weaponDef, missing model')
    end
  end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return weaponDefs

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
