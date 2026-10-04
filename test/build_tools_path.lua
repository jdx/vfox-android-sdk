local plugin_dir = assert(arg[1], "plugin directory argument is required")

local build_tools = {
    "/sdk/build-tools/9.0.0",
    "/sdk/build-tools/10.0.0",
    "/sdk/build-tools/35.0.0",
    "/sdk/build-tools/36.0.0",
}

package.preload.file = function()
    return {
        exists = function(path)
            return path == "/sdk/build-tools" or path == "/sdk/platform-tools" or path == "/sdk/emulator"
        end,
        join_path = function(...)
            return table.concat({ ... }, "/")
        end,
        list = function(path)
            assert(path == "/sdk/build-tools", "build-tools should be listed")
            return build_tools
        end,
        stat = function(path)
            for _, build_tool in ipairs(build_tools) do
                if path == build_tool then
                    return { is_dir = true }
                end
            end
            return nil
        end,
    }
end

package.preload.semver = function()
    return {
        compare = function(left, right)
            local function parts(version)
                local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)$")
                return tonumber(major), tonumber(minor), tonumber(patch)
            end
            local left_major, left_minor, left_patch = parts(left)
            local right_major, right_minor, right_patch = parts(right)
            for _, pair in ipairs({
                { left_major, right_major },
                { left_minor, right_minor },
                { left_patch, right_patch },
            }) do
                if pair[1] ~= pair[2] then
                    return pair[1] > pair[2] and 1 or -1
                end
            end
            return 0
        end,
    }
end

PLUGIN = {}
assert(loadfile(plugin_dir .. "/hooks/env_keys.lua"))()

local function path_values(options)
    local env = PLUGIN:EnvKeys({ path = "/sdk", version = "13.0", options = options })
    local values = {}
    for _, entry in ipairs(env) do
        if entry.key == "PATH" then
            table.insert(values, entry.value)
        end
    end
    return values
end

local values = path_values({})
assert(values[#values] == "/sdk/build-tools/36.0.0", "newest semantic build-tools version should be on PATH")

values = path_values({ build_tools = false })
for _, value in ipairs(values) do
    assert(not value:match("/build%-tools/"), "build_tools = false should omit build-tools from PATH")
end
