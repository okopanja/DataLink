local count = 0

local function counter()
	count = count + 1
	return count
end

SOUNDS_IDENTIFIERS = {
	ROTARY_TURNED = counter()
}

