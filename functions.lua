

function mesecons_debug.get_blockpos(pos)
	return {
		x = math.floor(pos.x / 16),
		y = math.floor(pos.y / 16),
		z = math.floor(pos.z / 16)
	}
end
