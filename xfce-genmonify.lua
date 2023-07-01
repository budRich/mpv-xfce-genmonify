-- SPDX-FileCopyrightText: 2022, budRich <at budlabs>
-- SPDX-License-Identifier: 0BSD

require 'os'
require 'io'
require 'string'
require 'mp.options'

local options = {
  pause_color        = "#EEEEEE",
  icon_click_command = "",
  icon_playing       = "mpv",
  icon_paused        = "media-playback-start",
  time_remaining     = "yes",
}

local last_cmd    = ""
local last_time   = ""
local loaded_file = ""
local title       = ""

read_options(options, "xfce-genmonify")

function genmonify_update()

  local cmd = 'genmonify --module media --msg "' .. loaded_file .. '"'

  if options.icon_click_command ~= "" then
    cmd = cmd .. " --iconclick " .. options.icon_click_command
  end

  if mp.get_property("pause") == "yes" then
    cmd = cmd .. " --foreground '" .. options.pause_color .. "'"
              .. " --icon " .. options.icon_paused
  else
    cmd = cmd .. " --icon " .. options.icon_playing
  end

  cmd = ('(%s " %s %s ") &'):format(cmd, title, last_time)

  if cmd ~= last_cmd then
    last_cmd = cmd
    os.execute(cmd)
  end
end

function timerupdate()
  local time = get_time()

  if time ~= last_time then
    last_time = time
    genmonify_update()
  end
end

t = mp.add_periodic_timer(3, timerupdate)

function on_seek(name, value)
  timerupdate()
end

function get_time()
  local time = 0

  if options.time_remaining == "yes" then
    time = math.floor(mp.get_property_number('playtime-remaining', 0))
  else
    time = math.floor(mp.get_property_number('time-pos', 0))
  end
  time = ('%02d:%02d'):format(math.floor(time / 3600), math.floor((time / 60) % 60))
  return time
end

function on_file_loaded(event)
  local filename = mp.get_property("filename")

  if filename:find('"') then
    loaded_file = os.capture("readlink -f '" .. mp.get_property("path") .. "'")
    loaded_file = loaded_file:gsub('"','\\"')
  else
    loaded_file = os.capture('readlink -f "' .. mp.get_property("path") .. '"')
  end

  title     = loaded_file:match("[/]([^/]+)[.][^.]+$")
  last_time = get_time()

  genmonify_update()
end

function on_pause_change(name, value)
  if title then
    genmonify_update()
    if value == true then
      t:stop()
    else
      t:resume()
    end
  end
end

function on_shutdown(event)
  os.execute('genmonify --module media -x &')
end

mp.register_event("start-file",      on_file_loaded)
-- mp.register_event('file-loaded',     on_file_loaded)
mp.register_event('seek',            on_seek)
mp.register_event('shutdown',        on_shutdown)
mp.observe_property('pause', 'bool', on_pause_change)

-- https://github.com/bamos/dotfiles/blob/master/.mpv/scripts/music.lua
-- Helper function to execute a command and return the output as a string.
-- Reference: http://stackoverflow.com/questions/132397
function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return string.sub(s, 0, -2) -- Use string.sub to trim the trailing newline.
end
