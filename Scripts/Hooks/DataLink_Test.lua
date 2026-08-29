-- Test_DataLink.lua
-- Unit tests for parse_ewr() from DataLink.lua.
-- Run standalone: lua Test_DataLink.lua
--
-- parse_ewr is a local function so it is copied here verbatim.
-- Keep it in sync with DataLink.lua whenever the function changes.

-- ── Minimal test harness ──────────────────────────────────────────────
local passed, failed = 0, 0

local function test(name, fn)
	local ok, err = pcall(fn)
	if ok then
		passed = passed + 1
		print("  PASS  " .. name)
	else
		failed = failed + 1
		print("  FAIL  " .. name .. "\n        " .. tostring(err))
	end
end

local function eq(a, b, label)
	if a ~= b then
		error((label and label .. ": " or "") ..
		      "expected " .. tostring(b) .. " got " .. tostring(a), 2)
	end
end

local function near(a, b, tol, label)
	tol = tol or 0.01
	if math.abs(a - b) > tol then
		error((label and label .. ": " or "") ..
		      "expected ~" .. b .. " got " .. a, 2)
	end
end

-- ── EWR functions (verbatim copy from DataLink.lua) ─────────────────
local MAX_CONTACTS = 10
local Logging = { info = function() end }   -- stub: suppress log output in tests

local function recognize_ewr_type(msg)
        local first_line = msg:match("^[^\n]*")
        if not first_line then return nil end
        if first_line:find("Contention EWR") then
                return "SPS"
        end
        return nil
end

local function parse_ewr_sps(msg)
        local contacts = {}
        for line in msg:gmatch("[^\n]+") do
                local brg, rng_val, rng_unit, alt_s, alt_unit, spd_val, spd_unit, hdg =
                        line:match("^%S+%s+(%d+)%s+([%d%.]+)%s+([%a]+)%s+([%d,]+)%s+([%a]+)%s+([%d%.]+)%s+([%a/]+)%s+(%d+)")
                if brg then
                        local rng = tonumber(rng_val)
                        if rng_unit:lower() == "nm" then rng = rng * 1.852 end
                        local alt = tonumber((alt_s:gsub(",", "")))
                        if alt_unit:lower() == "ft" then alt = alt * 0.3048 end
                        local spd = tonumber(spd_val)
                        if spd_unit:lower() == "knts" or spd_unit:lower() == "kts" then spd = spd * 1.852 end
                        table.insert(contacts, {
                                brg = tonumber(brg), rng = rng, alt = alt, spd = spd, hdg = tonumber(hdg),
                        })
                        if #contacts >= MAX_CONTACTS then break end
                end
        end
        return #contacts > 0 and contacts or nil
end

local function parse_ewr(msg)
        local ewr_type = recognize_ewr_type(msg)
        if not ewr_type then return nil end
        if ewr_type == "SPS" then return parse_ewr_sps(msg) end
        return nil
end
-- ── Fixtures ──────────────────────────────────────────────────────────

-- SI units (km / m / km/h)
local MSG_KM = [[
Contention EWR | Picture Report

TYPE            BRG         RNG         ALT                  SPD            HDG         Aspect 

FA-18C_hornet   047   244.3 Km      868 m      839 Km/h         255         Hot

FA-18C_hornet   006   326.2 Km       13,000 m     1025 Km/h         188         Hot
]]

-- Imperial units (NM / ft / Knts)
local MSG_NM = [[
Contention EWR | Picture Report

TYPE            BRG         RNG         ALT                  SPD            HDG         Aspect 

FA-18C_hornet   178    63.2 NM        6,000 ft      355 Knts         130         Flank Left
]]

-- 15 contacts — should be capped at MAX_CONTACTS
local many_lines = { "Contention EWR | Picture Report\n\n" }
for i = 1, 15 do
	many_lines[#many_lines + 1] = string.format(
		"FA-18C_hornet   %03d   100.0 Km      1000 m      500 Km/h         090         Hot\n", i)
end
local MSG_MANY = table.concat(many_lines)

-- ── Tests ─────────────────────────────────────────────────────────────
print("=== Test_DataLink: parse_ewr ===\n")


-- recognize_ewr_type
test("recognize_ewr_type: SPS for Contention EWR header", function()
        eq(recognize_ewr_type("Contention EWR | Picture Report\n..."), "SPS")
end)

test("recognize_ewr_type: nil for unrelated message", function()
        assert(recognize_ewr_type("Hello world") == nil)
end)

test("recognize_ewr_type: nil for empty string", function()
        assert(recognize_ewr_type("") == nil)
end)

-- Rejection cases (via dispatcher)
test("nil for non-EWR message", function()
	assert(parse_ewr("Hello world") == nil)
end)

test("nil for empty string", function()
	assert(parse_ewr("") == nil)
end)

test("nil when header present but no contact lines", function()
	assert(parse_ewr("Contention EWR | Picture Report\n\nTYPE BRG RNG ALT SPD HDG\n") == nil)
end)

-- SI units — detection and contact count
test("returns table for SI-unit message", function()
	assert(parse_ewr(MSG_KM) ~= nil)
end)

test("parses two contacts", function()
	eq(#parse_ewr(MSG_KM), 2, "contact count")
end)

-- SI units — contact 1 field values
test("contact 1 BRG", function()
	eq(parse_ewr(MSG_KM)[1].brg, 47)
end)

test("contact 1 RNG (km, no conversion)", function()
	near(parse_ewr(MSG_KM)[1].rng, 244.3)
end)

test("contact 1 ALT (m, no conversion)", function()
	near(parse_ewr(MSG_KM)[1].alt, 868)
end)

test("contact 1 SPD (km/h, no conversion)", function()
	near(parse_ewr(MSG_KM)[1].spd, 839)
end)

test("contact 1 HDG", function()
	eq(parse_ewr(MSG_KM)[1].hdg, 255)
end)

-- SI units — contact 2 (comma-formatted altitude)
test("contact 2 ALT with comma separator (13,000 m => 13000)", function()
	near(parse_ewr(MSG_KM)[2].alt, 13000)
end)

test("contact 2 SPD", function()
	near(parse_ewr(MSG_KM)[2].spd, 1025)
end)

test("contact 2 HDG", function()
	eq(parse_ewr(MSG_KM)[2].hdg, 188)
end)

-- Imperial units — conversion
test("NM => km  (63.2 NM = 117.05 km)", function()
	near(parse_ewr(MSG_NM)[1].rng, 63.2 * 1.852, 0.01)
end)

test("ft => m  (6,000 ft = 1828.8 m)", function()
	near(parse_ewr(MSG_NM)[1].alt, 6000 * 0.3048, 0.5)
end)

test("Knts => km/h  (355 Knts = 657.46 km/h)", function()
	near(parse_ewr(MSG_NM)[1].spd, 355 * 1.852, 0.01)
end)

test("BRG and HDG preserved under imperial unit message", function()
	local c = parse_ewr(MSG_NM)[1]
	eq(c.brg, 178)
	eq(c.hdg, 130)
end)

-- MAX_CONTACTS cap
test("caps result at MAX_CONTACTS (10) when 15 lines present", function()
	eq(#parse_ewr(MSG_MANY), 10)
end)

-- ── Summary ───────────────────────────────────────────────────────────
print(string.format("\n%d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
