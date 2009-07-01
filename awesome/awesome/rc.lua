---------------------------------------------
-- Awesome 3 (git) configuration file by | --
---------------------------------------------
io.stderr:write('\n::: Entered rc.lua: ', os.time(), ' time_t :::\n\n')

--{{{1 Imports

-- Load standard libraries
require('awful')
require('naughty')
require('beautiful')

-- Special stuff. :)
require('markup')
require('widgets')
require('invaders')

--{{{1 Initialize some stuff

tags               = {}
statusbar          = {}
promptbox          = {}
taglist            = {}
tasklist           = {}
layoutbox          = {}
settings           = {}
settings.apps      = {}
settings.audio     = {}
settings.keys      = {}
settings.ckeys     = {}
settings.tag_props = {}

--{{{1 Variables

settings.time_format   = '%H:%M:%S'
settings.date_format   = '%Y/%m/%d'
settings.modmask       = 'Mod4'
settings.net_interface = 'eth0'

-- xprop | awk -F '"' '/^WM_CLASS/ { printf("%s:%s:",$4,$2) }; /^WM_NAME/ { printf("%s\n",$2) }'
settings.win_info = 'xmessage -c "$(xprop | '
                  ..'awk -F \'"\' \'/^WM_CLASS/ '
                  ..'{ printf("%s:%s:",$4,$2) }; /^WM_NAME/ '
                  ..'{ printf("%s\\n",$2) }\')"'

settings.apps.term        = 'urxvtc' or 'urxvt'
settings.apps.browser     = 'firefox'
settings.apps.mailagent   = 'sylpheed'
settings.apps.screensaver = 'slock'
settings.apps.screenie    = 'screenie'
settings.apps.ut2004      = 'aoss ut2004'
settings.apps.ut2004_borg = 'aoss ut2004 75.126.220.122:8887'
settings.apps.nexuiz      = 'nexuiz-sdl-svn'

settings.audio.Up   = 'amixer set Master 2+%'
settings.audio.Down = 'amixer set Master 2-%'
settings.audio.Mute = 'amixer set Master toggle'
settings.audio.Prev = 'mocp --previous'
settings.audio.Togg = 'mocp --toggle-pause'
settings.audio.Next = 'mocp --next'
settings.audio.Stop = 'mocp --stop'

settings.theme_path = awful.util.getdir('config') .. '/themes/zenmine'

if settings.theme_path then
	beautiful.init(settings.theme_path)
else
	beautiful.init('/usr/share/awesome/themes/default/theme')
end

-- The layouts we will use
settings.layouts =
{
	awful.layout.suit.tile,
	awful.layout.suit.tile.left,
	awful.layout.suit.tile.bottom,
--	awful.layout.suit.tile.top,
	awful.layout.suit.fair,
--	awful.layout.suit.fair.horizontal,
	awful.layout.suit.max,
--	awful.layout.suit.max.fullscreen,
--	awful.layout.suit.magnifier,
	awful.layout.suit.floating,
}

-- The syntactical hell used here makes me want to eat babies.
settings.rules =
{
	[{ class = 'Inkscape'                             }] = { tag = 3                },
	[{ class = 'Gran Paradiso'                        }] = { tag = 2                },
	[{ class = 'Firefox'                              }] = { tag = 1                },
	[{ class = 'Sylpheed'                             }] = { tag = 5                },
	[{ class = 'Pidgin'                               }] = { tag = 4                },
	[{ class = 'Xmessage'                             }] = { float = true           },
	[{ class = 'XFontSel'                             }] = { float = true           },
	[{ title = 'glxgears'                             }] = { float = true           },
	[{ class = 'Gnome-mplayer'                        }] = { float = true           },
	[{ class = 'xine', instance = 'xine Video Window' }] = { float = true           },
	[{ class = 'Sylpheed', instance = 'compose'       }] = { tag = 5, float = true  },
	[{ class = 'Gimp'                                 }] = { tag = 3, float = true  },
}

--{{{1 Tags

settings.tag_props =
{
	{ name = '1-web',   layout = settings.layouts[1], mwfact = 0.6 },
	{ name = '2-dev',   layout = settings.layouts[1], mwfact = 0.6 },
	{ name = '3', layout = settings.layouts[3], },
	{ name = '4',   layout = settings.layouts[1], },
	{ name = '5',  layout = settings.layouts[4], },
  { name = '6',  layout = settings.layouts[4], },
  { name = '7',  layout = settings.layouts[4], },
  { name = '8',  layout = settings.layouts[4], },
  { name = '9',  layout = settings.layouts[4], }
}

for s = 1, screen.count() do
	tags[s] = { }
	for i, v in ipairs(settings.tag_props) do
		tags[s][i] = tag(v.name)
		tags[s][i].screen = s
		awful.tag.setproperty(tags[s][i], 'layout',  v.layout )
		awful.tag.setproperty(tags[s][i], 'mwfact',  v.mwfact )
		awful.tag.setproperty(tags[s][i], 'nmaster', v.nmaster)
		awful.tag.setproperty(tags[s][i], 'ncols',   v.ncols  )
	end
	tags[s][1].selected = true
end

--{{{1 Menu

-- Submenu
settings.apps.awesomemenu =
{
	{ 'Edit config', settings.apps.term .. ' -e vim ' .. awful.util.getdir('config') .. '/rc.lua' },
	{ 'Restart',     awesome.restart                                          },
	{ 'Quit',        awesome.quit                                             },
}

-- Mainmenu
settings.apps.mainmenu = awful.menu.new(
{
	items =
	{
		{ 'Terminal', settings.apps.term                     },
		{ 'Firefox',  settings.apps.browser                  },
		{ 'Gimp',     'gimp'                                 },
		{ 'Screen',   settings.apps.term .. ' -e screen -RR' },
		{ 'Mocp',     settings.apps.term .. ' -e mocp'       },
		{ 'Awesome',  settings.apps.awesomemenu              },
	},
})

--{{{1 Widgets

-- Note: Some funtions used here are used from the previously imported functions.lua

-- Simple spacer we can use for cleaner code
spacer = ' '
spacerwidget = widget({ type = 'textbox', align = 'right' })
spacerwidget.text = spacer

-- Create network in/out widget.
netwidget = widget({ type='textbox', align = 'right' })
netwidget.text = net_info(settings.net_interface, '#ffe677')

-- Create load average widget.
loadwidget = widget({ type = 'textbox', align = 'right' })
loadwidget.text = markup.bold('Load') .. ': ' .. load_info()

-- Create HD-related widgets. (2)
hdtextwidget = widget({ type = 'textbox', align = 'right' })
hdtextwidget.text = markup.bold(' HD ')

hdbarwidget                = widget({ type = 'progressbar', align = 'right' })
hdbarwidget.width          = 12
hdbarwidget.height         = 1
hdbarwidget.gap            = 1
hdbarwidget.border_padding = 1
hdbarwidget.border_width   = 1
hdbarwidget.ticks_count    = 7
hdbarwidget.vertical       = true
hdbarwidget:bar_properties_set(
	'hd',
	{
		bg = beautiful.bg_normal,
		fg = beautiful.fg_focus,
		border_color = beautiful.border_focus,
		min_value = 0,
		max_value = 100,
	}
)
hdbarwidget:bar_data_add('hd', hd_info('progressbar'))
hdbarwidget.mouse_enter = function () hd_naughty = hd_info('popup') end
hdbarwidget.mouse_leave = function () naughty.destroy(hd_naughty)   end

-- Create the memory-related widgets. (2)
memtextwidget = widget({ type = 'textbox', align = 'right' })
memtextwidget.text = markup.bold(' Mem ')

membarwidget                = widget({ type = 'progressbar', align = 'right' })
membarwidget.width          = 12
membarwidget.height         = 1
membarwidget.gap            = 1
membarwidget.border_padding = 1
membarwidget.border_width   = 1
membarwidget.ticks_count    = 7
membarwidget.vertical       = true
membarwidget:bar_properties_set(
	'mem',
	{
		bg = beautiful.bg_normal,
		fg = beautiful.fg_focus,
		border_color = beautiful.border_focus,
		min_value = 0,
		max_value = 100,
	}
)
membarwidget:bar_data_add('mem', memory_info('progressbar'))
membarwidget.mouse_enter = function () memory_naughty = memory_info('popup') end
membarwidget.mouse_leave = function () naughty.destroy(memory_naughty)    end

-- Create volume widget.
volwidget = widget({ type = 'textbox', align = 'right' })
volwidget.text = volume_info('#A1DFF5')

-- Create temperature widget.
-- tempwidget = widget({ type = 'textbox', align = 'right' })
-- tempwidget.text = temperature_info('#CFFB7E')

-- Create the clock widget
clockwidget = widget({ type = 'textbox', align = 'right' })
clockwidget.text = clock_info(settings.date_format, settings.time_format)

-- Create the mocp widget
mocwidget = widget({ type = 'textbox', align = 'right' })
mocwidget.text = moc_info('textbox')
mocwidget.mouse_enter = function () moc_naughty = moc_info('popup') end
mocwidget.mouse_leave = function () naughty.destroy(moc_naughty)    end

-- Create a system tray
systray = widget({ type = 'systray', align = 'right' })

-- Initialize which buttons do what when clicking the taglist
taglist.buttons =
{
	button({                  }, 1, awful.tag.viewonly                                ),
	button({ settings.modmask }, 1, awful.client.movetotag                            ),
	button({                  }, 3, function (tag) tag.selected = not tag.selected end),
	button({ settings.modmask }, 3, awful.client.toggletag                            ),
	button({                  }, 4, awful.tag.viewnext                                ),
	button({                  }, 5, awful.tag.viewprev                                ),
}

-- Initialize which buttons do what when clicking the tasklist
tasklist.buttons =
{
	button({ }, 1, function (c) client.focus = c; c:raise()       end),
	button({ }, 3, function ( ) awful.menu.clients({ width=250 }) end),
	button({ }, 4, function ( ) awful.client.focus.byidx( 1)      end),
	button({ }, 5, function ( ) awful.client.focus.byidx(-1)	  end),
}

-- From here on, everything gets created for every screen
for s = 1, screen.count() do

	-- Promptbox (pops up with mod + p)
	promptbox[s] = widget({ type = 'textbox', align = "left" })

	-- Layouticon for the current tag
	layoutbox[s] = widget({ type = 'imagebox', align = "left" })
	layoutbox[s]:buttons(
	{
		button({ }, 1, function () awful.layout.inc(settings.layouts,  1) end),
		button({ }, 3, function () awful.layout.inc(settings.layouts, -1) end),
		button({ }, 4, function () awful.layout.inc(settings.layouts,  1) end),
		button({ }, 5, function () awful.layout.inc(settings.layouts, -1) end),
	})

	-- Create the taglist
	taglist[s] = awful.widget.taglist.new(s, awful.widget.taglist.label.all, taglist.buttons)

	-- Create the tasklist
	tasklist[s] = awful.widget.tasklist.new(
		function(c)
			if c == client.focus and c ~= nil then
				return markup.fg.focus(awful.util.escape(c.name))
			end
			-- For all window titles to be shown:
			-- return awful.widget.tasklist.label.currenttags(c, s)
		end,
		tasklist.buttons
	)

	-- Finally, create the statusbar (called wibox), and set its properties
	statusbar[s] = wibox(
	{
		position = 'top',
		height   = '18',
		fg       = beautiful.fg_normal,
		bg       = beautiful.bg_normal,
	})

	-- Add our widgets to the wibox
	statusbar[s].widgets =
	{
		layoutbox[s],
		taglist[s],
		tasklist[s],
		promptbox[s],
		mocwidget,
		spacerwidget,
		netwidget,
		spacerwidget,
		loadwidget,
		spacerwidget,
		hdtextwidget,
		hdbarwidget,
		spacerwidget,
		memtextwidget,
		membarwidget,
		spacerwidget,
		volwidget,
		spacerwidget,
		--tempwidget,
		spacerwidget,
		clockwidget,
		spacerwidget,
		s == 1 and systray or nil,
	}

	-- Add it to each screen
	statusbar[s].screen = s
end

--{{{1 Bindings

--  What happens when we click the desktop
root.buttons(
{
	button({ }, 3, function () settings.apps.mainmenu:toggle() end),
	button({ }, 4, awful.tag.viewnext               ),
	button({ }, 5, awful.tag.viewprev               ),
})

settings.keys =
{
	-- Another little tag navigation helper.
	key({ settings.modmask, }, 'Left',   awful.tag.viewprev),
	key({ settings.modmask, }, 'Right',  awful.tag.viewnext),

	-- Launching programs.
	key({ settings.modmask,           }, 'Return', function () awful.util.spawn(settings.apps.term       ) end),
	key({ settings.modmask, 'Shift'   }, 'Return', function () awful.util.spawn(settings.apps.browser    ) end),
	key({                             }, '#236',   function () awful.util.spawn(settings.apps.mailagent  ) end),
	key({                             }, '#223',   function () awful.util.spawn(settings.apps.screensaver) end),
	key({                             }, '#229',   function () awful.util.spawn(settings.apps.screenie   ) end),
	key({ settings.modmask, 'Shift'   }, 'i',      function () awful.util.spawn(settings.win_info        ) end),
	key({ settings.modmask,           }, 'i',      function () invaders.run({ solidbg = "#000000" })       end),
	key({ settings.modmask, 'Shift'   }, 'u',      function () awful.util.spawn(settings.apps.ut2004     ) end),
	key({ settings.modmask, 'Mod1'    }, 'u',      function () awful.util.spawn(settings.apps.ut2004_borg) end),
	key({ settings.modmask, 'Shift'   }, 'n',      function () awful.util.spawn(settings.apps.nexuiz     ) end),

  -- dmenu
	key({ settings.modmask,           }, 'p',      function () awful.util.spawn("`dmenu_path | dmenu -b`") end),

	-- Volume control.
	key({ }, '#121', function () awful.util.spawn(settings.audio.Mute) end),
	key({ }, '#122', function () awful.util.spawn(settings.audio.Down) end),
	key({ }, '#123', function () awful.util.spawn(settings.audio.Up  ) end),

	-- Media player controls.
	key({ }, '#173', function () awful.util.spawn(settings.audio.Prev) end),
	key({ }, '#172', function () awful.util.spawn(settings.audio.Togg) end),
	key({ }, '#171', function () awful.util.spawn(settings.audio.Next) end),
	key({ }, '#174', function () awful.util.spawn(settings.audio.Stop) end),

	-- Client window manipulation.
	key({ settings.modmask,           }, 'u', awful.client.urgent.jumpto                 ),
	key({ settings.modmask, 'Shift'   }, 'j', function () awful.client.swap.byidx( 1) end),
	key({ settings.modmask, 'Shift'   }, 'k', function () awful.client.swap.byidx(-1) end),

	-- Client window focusing/cycling.
	key({ settings.modmask,           }, 'j',   function () awful.client.focus.byidx( 1) end),
	key({ settings.modmask,           }, 'k',   function () awful.client.focus.byidx(-1) end),

	key({ settings.modmask,           }, 'Tab', function () awful.client.focus.byidx( 1)          end),
	key({ settings.modmask, 'Shift'   }, 'Tab', function () awful.client.focus.history.previous() end),

	-- Bindings that affect dimensions.
	key({ settings.modmask,           }, 'h', function () awful.tag.incmwfact(  -0.025) end),
	key({ settings.modmask,           }, 'l', function () awful.tag.incmwfact(   0.025) end),
	key({ settings.modmask, 'Mod1'    }, 'j', function () awful.client.incwfact(-0.200) end),
	key({ settings.modmask, 'Mod1'    }, 'k', function () awful.client.incwfact( 0.200) end),
	
	key({ settings.modmask, 'Shift'   }, 'h', function () awful.tag.incnmaster( 1) end),
	key({ settings.modmask, 'Shift'   }, 'l', function () awful.tag.incnmaster(-1) end),
	key({ settings.modmask, 'Control' }, 'h', function () awful.tag.incncol(    1) end),
	key({ settings.modmask, 'Control' }, 'l', function () awful.tag.incncol(   -1) end),

	-- Layout cycling.
	key({ settings.modmask, 'Control' }, 'Left',  function () awful.layout.inc(settings.layouts,  1)       end),
	key({ settings.modmask, 'Control' }, 'Right', function () awful.layout.inc(settings.layouts, -1)       end),
	key({ settings.modmask,           }, 't',     function () awful.layout.set(awful.layout.suit.tile    ) end),
	key({ settings.modmask,           }, 'e',     function () awful.layout.set(awful.layout.suit.fair    ) end),
	key({ settings.modmask,           }, 'f',     function () awful.layout.set(awful.layout.suit.floating) end),
	key({ settings.modmask,           }, 'm',     function () awful.layout.set(awful.layout.suit.max     ) end),
	key({ settings.modmask, 'Shift'   }, 'q',     awesome.quit   ),
	key({ settings.modmask, 'Control' }, 'r',     awesome.restart),
}

settings.ckeys =
{
	key({ settings.modmask,           }, 'c',         function (c) c:kill()                         end),
	key({ settings.modmask,           }, 'r',         function (c) c:redraw()                       end),
	key({ settings.modmask, 'Shift'   }, 'space',     awful.client.floating.toggle                     ),  
	key({ settings.modmask,           }, 'backslash', function (c) c:swap(awful.client.getmaster()) end),
	key({ settings.modmask,           }, 'o',         awful.client.movetoscreen                        ),  
	key({ settings.modmask, 'Shift'   }, 't',         awful.client.togglemarked                        ),
	key({ settings.modmask,           }, 'm',
		function (c) 
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end),
}

-- Tag manipulation
keynumber = 9
for i = 1, keynumber do
	-- Mod + # == Switch to tag.
	table.insert(
		settings.keys,
		key(
			{ settings.modmask }, i,
			function ()
				local screen = mouse.screen
				if tags[screen][i] then
					awful.tag.viewonly(tags[screen][i])
				end
			end
		)
	)
	-- Mod + Control + # == Select tags.
	table.insert(
		settings.keys,
		key(
			{ settings.modmask, 'Control' }, i,
			function ()
				local screen = mouse.screen
				if tags[screen][i] then
					tags[screen][i].selected = not tags[screen][i].selected
				end
			end
		)
	)
	-- Mod + Shift + # == Move to tag.
	table.insert(
		settings.keys,
		key(
			{ settings.modmask, 'Shift' }, i,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.movetotag(tags[client.focus.screen][i])
				end
			end
		)
	)
	-- Mod + Control + Shift + # == Put focused window on selected tag.
	table.insert(
		settings.keys,
		key(
			{ settings.modmask, 'Control', 'Shift' }, i,
			function ()
				if client.focus and tags[client.focus.screen][i] then
					awful.client.toggletag(tags[client.focus.screen][i])
				end
			end
		)
	)
end

-- Prompt similar to dwm's dmenu.
-- table.insert(
-- 	settings.keys,
-- 	key(
-- 		{ settings.modmask }, 'p',
-- 		function ()
-- 			awful.prompt.run(
-- 				{ prompt = markup.fg.focus(' Run: '), bg_cursor = beautiful.fg_focus },
-- 				promptbox[mouse.screen],
-- 				awful.util.spawn,
-- 				awful.completion.shell,
-- 				awful.util.getdir('cache') .. '/history'
-- 			)
-- 		end
-- 	)
-- )

-- Calculator prompt with naughty reply.
table.insert(
	settings.keys,
	key(
		{ settings.modmask, 'Shift' }, 'c',
		function ()
			val = nil
		    awful.prompt.run(
				{
					bg_cursor = beautiful.fg_focus,
					text      = val and tostring(val),
					selectall = true,
					prompt    = markup.fg.focus(' Calc: ')
				},
				promptbox[mouse.screen],
				function(expr)
					val = awful.util.eval(expr)
					naughty.notify(
					{
						text = expr .. ' = ' .. markup.fg.focus(val),
						timeout = 5,
						run = function()
							io.popen('echo ' .. val .. ' | xsel -i'):close()
						end,
					})
				end,
				nil,
				awful.util.getdir('cache') .. '/calc'
			)
		end
	)
)

table.insert(
	settings.keys,
	key(
		{ settings.modmask }, 'd',
		function ()
			info = true
			awful.prompt.run(
				{ prompt = markup.fg.focus(' Dict: '), bg_cursor = beautiful.fg_focus }, 
				promptbox[mouse.screen],
				function (word)
					local f = io.popen('dict -d wn ' .. word .. ' 2>&1')
					local fr = ''
					for line in f:lines() do
					fr = fr .. line .. '\n'
					end
					f:close()
					naughty.notify(
					{
						text = awful.util.escape(fr),
						timeout = 30,
						width   = 400,
					})
				end,
				nil,
				awful.util.getdir('cache') .. '/dict'
			)
		end
	)
)

-- Hide the statusbar with Mod + b.
table.insert(
	settings.keys,
	key(
		{ settings.modmask }, 'b',
		function ()
			if  statusbar[mouse.screen].screen then
				statusbar[mouse.screen].screen = nil
			else
				statusbar[mouse.screen].screen = mouse.screen
			end
		end
	)
)

-- Set keys
root.keys(settings.keys)

--{{{1 Hooks

-- Gets executed when focusing a client
awful.hooks.focus.register(
	function (c)
		if not awful.client.ismarked(c) then
			c.border_color = beautiful.border_focus
		end
	end
)

-- Gets executed when unfocusing a client
awful.hooks.unfocus.register(
	function (c)
		if not awful.client.ismarked(c) then
			c.border_color = beautiful.border_normal
		end
	end
)

-- Gets executed when marking a client
awful.hooks.marked.register(
	function (c)
		c.border_color = beautiful.border_marked
	end
)

-- Gets executed when unmarking a client
awful.hooks.unmarked.register(
	function (c)
		c.border_color = beautiful.border_focus
	end
)

-- Gets executed when the mouse enters a client
awful.hooks.mouse_enter.register(
	function (c)
		if awful.client.focus.filter(c) then
			client.focus = c
		end
	end
)

-- Gets executed when a new client appears
awful.hooks.manage.register(
	function (c)
		-- Set key bindings
		c:keys(settings.ckeys)

		if not startup and awful.client.focus.filter(c) then
			c.screen = mouse.screen
		end

		if use_titlebar then
			-- Add a titlebar
			awful.titlebar.add(c, { modkey = modkey })
		end

		-- Add mouse binds
		c:buttons(
		{
			button({                  }, 1, function (c) client.focus = c end),
			button({ settings.modmask }, 1, awful.mouse.client.move          ),
			button({ settings.modmask }, 3, awful.mouse.client.resize        ),
		})

		-- Prevent new clients from becoming master
		awful.client.setslave(c)

		-- Ignore size hints usually given out by terminals
		-- (used to prevent gaps between windows)
		c.size_hints_honor = false

		c.border_width = beautiful.border_width
		c.border_color = beautiful.border_normal
		client.focus = c

		----------------------------------------------------------------------------------------------------------
		-- 1 = class, 2 = instance, 3 = title, 4 = screen, 5 = tag, 6 = floating
		local bestmatch, isfloat, isscreen, istag
		bestmatch = 0
		for match, apply in pairs(settings.rules) do
			local x = 0
			if match['class']    and c.class    and c.class    == match['class']                then x = x + 1 end
			if match['instance'] and c.instance and c.instance == match['instance']             then x = x + 1 end
			if match['title']    and c.name     and string.match(c.name, match['title']) ~= nil then x = x + 1 end
			if x > bestmatch then
				isscreen  = apply['screen']
				istag     = apply['tag']
				isfloat   = apply['float']
				bestmatch = x
			end
		end

		if isfloat ~= nil and isfloat ~= awful.client.floating.get(c) then
			awful.client.floating.set(c, isfloat)
		end

		if isscreen ~= nil and istag ~= nil then
			awful.client.movetotag(tags[isscreen][istag], c)
			c.screen = isscreen
			c.tag    = istag
		else
			if isscreen ~= nil then
				awful.client.movetoscreen(c, isscreen)
				c.screen = isscreen
			end
			if istag ~= nil then
				awful.client.movetotag(tags[mouse.screen][istag], c)
				c.tag = istag
			end
		end
		----------------------------------------------------------------------------------------------------------
	end
)

-- Gets executed when arranging the screen
-- (as in: tag switch, new client, etc)
awful.hooks.arrange.register(
	function (screen)
		-- Update the layoutbox image
		local layout = awful.layout.getname(awful.layout.get(screen))

		if layout and beautiful['layout_' .. layout] then
			layoutbox[screen].image = image(beautiful['layout_' .. layout])
		else
			layoutbox[screen].image = nil
		end
		
		-- Give focus to the latest client in history if no window has focus
		if not client.focus then
			local c = awful.client.focus.history.get(screen, 0)
			if c then client.focus = c end
		end
		-- dwm border mod
		local tiledclients = awful.client.tiled(screen)
		if #tiledclients > 0 then
			if (#tiledclients == 1) or (layout == 'max') then
				tiledclients[1].border_width = 0
			else
				for unused, current in pairs(tiledclients) do
					current.border_width = beautiful.border_width
				end
			end
		end
	end
)

---- Timed hooks for the widget functions
awful.hooks.timer.register(
	1, -- every 1 second
	function ()
		clockwidget.text = clock_info(
			settings.date_format,
			settings.time_format
		)
		netwidget.text = net_info(settings.net_interface, '#ffe677')
		volwidget.text = volume_info('#A1DFF5')
	end
)

awful.hooks.timer.register(
	5, -- every 10 seconds
	function ()
		 mocwidget.text = moc_info('textbox')
		-- tempwidget.text = temperature_info('#CFFB7E')
	end
)

awful.hooks.timer.register(
	60, -- every minute
	function ()
		loadwidget.text = markup.bold('Load') .. ': ' .. load_info()
		membarwidget:bar_data_add('mem', memory_info('progressbar'))
		hdbarwidget:bar_data_add( 'hd',      hd_info('progressbar'))
	end
)
