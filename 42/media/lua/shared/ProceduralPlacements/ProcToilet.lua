BanditProc = BanditProc or {}

function BanditProc.Toilet (sx, sy, sz)
	BanditBasePlacements.IsoObject ("floors_exterior_street_01_17", sx + 1, sy + 1, sz + 0)
	BanditBasePlacements.IsoObject ("fixtures_bathroom_02_22", sx + 1, sy + 1, sz + 0)
	BanditBasePlacements.IsoObject ("fixtures_bathroom_02_5", sx + 1, sy + 1, sz + 0)
	BanditBasePlacements.IsoObject ("ceilings_01_0", sx + 1, sy + 1, sz + 1)
	BanditBasePlacements.IsoObject ("fixtures_bathroom_02_7", sx + 1, sy + 1, sz + 1)
	BanditBasePlacements.IsoObject ("fixtures_bathroom_02_1", sx + 1, sy + 2, sz + 0)
	BanditBasePlacements.IsoObject ("fixtures_bathroom_02_10", sx + 2, sy + 1, sz + 0)
	BanditBasePlacements.IsoDoor ("fixtures_bathroom_02_16", sx + 2, sy + 1, sz + 0)
	BanditBasePlacements.IsoObject ("fixtures_bathroom_02_3", sx + 2, sy + 2, sz + 0)
end

