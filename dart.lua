VERSION = "2.0.2"

local micro = import("micro")
local config = import("micro/config")
local shell = import("micro/shell")
local buffer = import("micro/buffer")

-- outside init because we want these options to take effect before
-- buffers are initialized
config.RegisterCommonOption("rust", "format", true)

function init()
    config.MakeCommand("rustfmt", dartfmt, config.NoComplete)

    config.AddRuntimeFile("rust", config.RTHelp, "help/rust-plugin.md")
end

function onSave(bp)
    if bp.Buf:FileType() == "dart" then
		if bp.Buf.Settings["rust.format"] then
            dartfmt(bp)
        end
    end

    return true
end

function dartfmt(bp)
    bp:Save()
    local _, err = shell.RunCommand("cargo format " .. bp.Buf.Path)
    if err ~= nil then
        micro.InfoBar():Error(err)
        return
    end

    bp.Buf:ReOpen()
end

function renameStderr(err)
    micro.Log(err)
    micro.InfoBar():Message(err)
end

function renameExit(output, args)
    local bp = args[1]
    bp.Buf:ReOpen()
end
