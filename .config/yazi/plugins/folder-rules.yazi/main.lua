local function ends_with_any(str, list)
    for _, v in ipairs(list) do
        if str:ends_with(v) then
            return true
        end
    end
    return false
end

local function setup()
    ps.sub("ind-sort", function(opt)
        local cwd = cx.active.current.cwd

        if ends_with_any(cwd, { "Downloads", "Videos", "Screenshots", "Screen Recordings", "Beeper" }) then
            opt.by, opt.reverse, opt.dir_first = "mtime", true, false
        else
            opt.by, opt.reverse, opt.dir_first = "natural", false, true
        end
        return opt
    end)
end

return { setup = setup }
