-- The MIT License (MIT)

-- Copyright (c) 2014 Nathan Skillen

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

JSON = nil
nzbget_status_measure = nil
nzbget_queue_measure = nil

nzbget_title_meter = nil
nzbget_dl = {}

num_rows = nil

function Initialize()
	-- JSON.lua was written by Jeffrey Friedl, licensed CC-BY-3.0
	-- and was downloaded from http://regex.info/blog/lua/json
	JSON = assert(loadfile(SKIN:ReplaceVariables("#@#/JSON.lua")))()

	nzbget_status_measure = SKIN:GetMeasure("NZBGetStatusResponse")
	nzbget_queue_measure = SKIN:GetMeasure("NZBGetQueueResponse")

	nzbget_title_meter = SKIN:GetMeter("meterTitle")

	num_rows = tonumber(SKIN:ReplaceVariables("#NUM_ROWS#"))

	for i = 1, num_rows do
		nzbget_dl[i] = {}
		nzbget_dl[i]["label"] = SKIN:GetMeter("meterLabelDL"..i)
		nzbget_dl[i]["remSize"] = SKIN:GetMeter("meterRemSizeDL"..i)
		nzbget_dl[i]["bar"] = SKIN:GetMeasure("MeasureProgressDL"..i)
	end
end

function Update()
	local nzbget_status = JSON:decode(nzbget_status_measure:GetStringValue())

	if nzbget_status == nil then
		return
	end

	local status
	local speed = nzbget_status["DownloadRate"]
	local rate_key = 1
	local rates = { "B", "KB", "MB", "GB", "TB", "PB" }

	if nzbget_status["ServerPaused"] == true then
		status = "Paused"
	elseif nzbget_status["ServerStandBy"] == true then
		status = "Idle"
	else
		status = "Downloading"
	end

	while speed > 1024 do
		speed = speed / 1024
		rate_key = rate_key + 1
	end

	nzbget_title_meter:SetText(string.format("NZBGet - %s - %6.2f %s/s", status, speed, rates[rate_key]))

	local nzbget_queue = JSON:decode(nzbget_queue_measure:GetStringValue())

	for qPos = 1, (#nzbget_queue < num_rows and #nzbget_queue or num_rows) do
		local totalSize = nzbget_queue[qPos]["FileSizeMB"]
		local remSize = nzbget_queue[qPos]["RemainingSizeMB"]
		local pct = 1 - (remSize / totalSize)
		rate_key = 3
		while remSize > 1024 do
			remSize = remSize / 1024
			rate_key = rate_key + 1
		end
		remSize = string.format("%.2f %s", remSize, rates[rate_key])
		
		nzbget_dl[qPos]["label"]:SetText(nzbget_queue[qPos]["NZBName"])
		nzbget_dl[qPos]["remSize"]:SetText(remSize)
		SKIN:Bang("!SetOption", nzbget_dl[qPos]["bar"]:GetName(), "Formula", pct)
	end

	for qPos = (#nzbget_queue < num_rows and (#nzbget_queue + 1) or num_rows), num_rows do
		nzbget_dl[qPos]["label"]:SetText("")
		nzbget_dl[qPos]["remSize"]:SetText("")
		SKIN:Bang("!SetOption", nzbget_dl[qPos]["bar"]:GetName(), "Formula", 0)
	end
end