local special_dirs = { "Downloads", "Videos", "Screenshots", "Screen Recordings", "Beeper" }

local function setup()
	ps.sub("ind-sort", function(opt)
		local cwd = cx.active.current.cwd

		for _, dir in ipairs(special_dirs) do
			if cwd:ends_with(dir) then
				opt.by, opt.reverse, opt.dir_first = "mtime", true, false
				return opt
			end
		end

		opt.by, opt.reverse, opt.dir_first = "natural", false, true
		return opt
	end)
end

return { setup = setup }
