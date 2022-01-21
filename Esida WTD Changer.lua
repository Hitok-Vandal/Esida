script_name("Esida")
script_author("Alex_Benson")

local inicfg = require("inicfg")
local memory = require("memory")
local ffi = require 'ffi'
local cast = ffi.cast
local draw_dist = cast('float *', 0x00B7C4F0)

cast('unsigned char *', 0x005609FF)[0] = 0xEB
cast('unsigned char *', 0x00561344)[0] = 0xEB

local data =
{
	Settings =
	{
		Time = 12,
		Weather = 1,
		Distance = 900.0,
		Static = true
	}
}

function main()
	repeat wait(0) until isSampAvailable()
	local values = inicfg.load(data, "WTD Changer.ini")
	inicfg.save(values, "WTD Changer.ini")
	sampRegisterChatCommand("psettime", setTime)
	sampRegisterChatCommand("psetweather", setWeather)
	sampRegisterChatCommand("psetd", setDistance)
	sampRegisterChatCommand("setstatic", setStatic)
	sampRegisterChatCommand("shelp", help)
	sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Успешно загружен! Автор: {2090FF}Alex_Benson", -1)
	while true do
		wait(0)
		local values = inicfg.load(data, "WTD Changer.ini")
		if values.Settings.Static then
			if values.Settings.Time ~= memory.read(0xB70153, 1, false) then memory.write(0xB70153, values.Settings.Time, 1, false) end
			if values.Settings.Weather ~= memory.read(0xC81320, 2, false) then memory.write(0xC81320, values.Settings.Weather, 2, false) end
			if values.Settings.Distance ~= memory.read(0x00B7C4F0, 4, false) then weatmain(values.Settings.Distance) end
		end
	end
end

function setTime(time)
	local time = tonumber(time)
	if time < 0 or time > 23 then sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Правильный ввод: {2090FF}//t [0-23]", -1) else
		sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Время установлено на {2090FF}"..time, -1)
		local values = inicfg.load(data, "WTD Changer.ini")
		if values.Settings.Static then
			values.Settings.Time = time
			inicfg.save(values, "WTD Changer.ini")
		else memory.write(0xB70153, time, 1, false)
		end
	end
end

function help()
	sampShowDialog(1999, "Все команды скрипта:", string.format([[
{FF7F7F}Команды для взаимодействие с скриптом:
{2090FF}/shelp {FFFFFF}- Помощь в скрипте
{2090FF}/psettime [от 0 до 24] {FFFFFF}- Изменить локально время
{2090FF}/psetweather [от 0 до 45] {FFFFFF}- Изменить локально погоду
{2090FF}/psetd [от 101 до 3600] {FFFFFF}- Изменить дистанцию прорисовки
{2090FF}/setstatic [true/false] {FFFFFF}- Не позволять серверу менять погоду
]]),"Закрыть")
end

function setDistance(param)
	param = tonumber(param)
	if param > 3600.0 or param < 101.0 then sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Правильный ввод: {2090FF}//d [101-3600]") return false end
	weatmain(param)
	sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Дистанция прорисовки установлена на {2090FF}"..param, -1)
end

function weatmain(dist)
	local values = inicfg.load(data, "WTD Changer.ini")
	draw_dist[0] = dist
	values.Settings.Distance = dist
	inicfg.save(values, "WTD Changer.ini")
end

function setWeather(weather)
	local weather = tonumber(weather)
	if weather < 0 or weather > 45 then sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Правильный ввод: {2090FF}//w [0-45]", -1) else
		if message then
			sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Погода установлена на {2090FF}"..weather, -1)
		end
		local values = inicfg.load(data, "WTD Changer.ini")
		if values.Settings.Static then
			memory.write(0xC81320, weather, 2, false)
			memory.write(0xC81318, weather, 2, false)
			values.Settings.Weather = weather
			inicfg.save(values, "WTD Changer.ini")
		else
			memory.write(0xC81320, weather, 2, false)
		end
	end
end

function setStatic(static)
	if static == "true" then
		sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Static state: {2090FF}true", -1)
		local values = inicfg.load(data, "WTD Changer.ini")
		values.Settings.Static = true
		inicfg.save(values, "WTD Changer.ini")
	elseif static == "false" then
		sampAddChatMessage("{2090FF}Esida »  {FFFFFF}Static state: {2090FF}false", -1)
		local values = inicfg.load(data, "WTD Changer.ini")
		values.Settings.Static = false
		inicfg.save(values, "WTD Changer.ini")
	end
end
