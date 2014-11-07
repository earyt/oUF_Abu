local _, ns = ...

-- For handling everything with profiles and settings

-- [[ Utility Methods ]] --
local function initDB(db, defaults)
	if type(db) ~= "table" then db = {} end
	if type(defaults) ~= "table" then return db end
	for k, v in pairs(defaults) do
		if type(v) == "table" then
			db[k] = initDB(db[k], v)
		elseif type(v) ~= type(db[k]) then
			db[k] = v
		end
	end
	return db
end

local function cleanDB(db, defaults)
	if type(db) ~= "table" then return {} end
	if type(defaults) ~= "table" then return db end
	for k, v in pairs(db) do
		if type(v) == "table" then
			if not next(cleanDB(v, defaults[k])) then
				-- Remove empty subtables
				db[k] = nil
			end
		elseif v == defaults[k] then
			-- Remove default values
			db[k] = nil
		end
	end
	return db
end

local function isValidID(id)
	if type(id) ~= "string" or id == "" then
		return false 
	end
	return true
end


-- [[ Settings Profiles ]] --
function oUFAbu:CreateProfile(id)
	if isValidID(id) and not oUFAbuSettings[id] then
		oUFAbuSettings[id] = initDB(oUFAbuSettings[id], ns.defaultConfig)
		return true
	end
	return false
end

function oUFAbu:DeleteProfile(id)
	if not oUFAbuSettings[id] or id == 'Default' then return false end
	if ( id == self:GetProfileID() ) then
		self:SetProfile('Default')
	end

	oUFAbuSettings[id] = nil
	return true
end

function oUFAbu:GetSettings()
	return oUFAbuSettings[self:GetProfileID()]
end

function oUFAbu:GetAllProfiles()
	local tbl = {}
	for k, _ in pairs(oUFAbuSettings) do
		table.insert(tbl, k)
	end
	table.sort(tbl)
	return tbl
end

function oUFAbu:GetProfileID()
	return oUFAbuProfile['profile']
end

function oUFAbu:SetProfile(id)
	if oUFAbuSettings[id] then
		local oldID = self:GetProfileID() 
		if oldID ~= id then	-- Clean the old profile
			oUFAbuSettings[oldID] = cleanDB(oUFAbuSettings[oldID], ns.defaultConfig)
		end
		oUFAbuProfile['profile'] = id
		
		oUFAbuSettings[id] = initDB(oUFAbuSettings[id], ns.defaultConfig)

		ns.config = oUFAbuSettings[id]
		return true
	end
	return false
end

function oUFAbu:ResetProfile(id)
	if oUFAbuSettings[id] then
		wipe(oUFAbuSettings[id])
		oUFAbuSettings[id] = initDB(oUFAbuSettings[id], ns.defaultConfig)
	end
end

function oUFAbu:GetDefaultSettings()
	return ns.defaultConfig
end

-- [[ Aura Profiles ]] --
function oUFAbu:CreateAuraProfile(id)
	if isValidID(id) and not oUFAbuAuraFilters[id] then

		oUFAbuAuraFilters[id] = initDB(oUFAbuAuraFilters[id], ns.defaultAuras)
		return true
	end
	return false
end

function oUFAbu:DeleteAuraProfile(id)
	if (not oUFAbuAuraFilters[id]) or id == 'Default' then return false end
	if ( id == self:GetAuraProfileID() ) then
		self:SetAuraProfile('Default')
	end

	oUFAbuAuraFilters[id] = nil
	return true
end

function oUFAbu:GetAuraSettings()
	return oUFAbuAuraFilters[self:GetAuraProfileID()]
end

function oUFAbu:GetAuraProfileID()
	return oUFAbuProfile['auraprofile'] or 'Default'
end

function oUFAbu:GetAllAuraProfiles()
	local tbl = {}
	for k, _ in pairs(oUFAbuAuraFilters) do
		table.insert(tbl, k)
	end
	table.sort(tbl)
	return tbl
end

function oUFAbu:SetAuraProfile(id)
	if oUFAbuAuraFilters[id] then
		oUFAbuProfile['auraprofile'] = id
		self:UpdateAuraLists()
		return true
	end
	return false
end

function oUFAbu:ResetAuraProfile(id)
	if oUFAbuAuraFilters[id] then
		wipe(oUFAbuAuraFilters[id])
		oUFAbuAuraFilters[id] = initDB(oUFAbuAuraFilters[id], ns.defaultAuras)
	end
end

-- [[ Startup	]] --
function oUFAbu:SetupSettings()
	-- Per char
	_G.oUFAbuProfile = initDB(oUFAbuProfile, ns.defaultProfiles)

	-- Settings
	_G.oUFAbuSettings = initDB(oUFAbuSettings)
	self:CreateProfile('Default')
	self:SetProfile(self:GetProfileID())

	-- Auras
	_G.oUFAbuAuraFilters = initDB(oUFAbuAuraFilters)
	self:CreateAuraProfile('Default')
	self:SetAuraProfile(self:GetAuraProfileID())
end

-- [[ Cleaner 	]] --
function oUFAbu:PLAYER_LOGOUT(event)
	oUFAbuSettings[self:GetProfileID()] = cleanDB(oUFAbuSettings[self:GetProfileID()], ns.defaultConfig)
end
