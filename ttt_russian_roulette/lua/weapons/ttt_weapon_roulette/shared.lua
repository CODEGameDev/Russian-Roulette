AddCSLuaFile()
include("lib/shadow_text.lua")

SWEP.HoldType              = "pistol"

if CLIENT then
   SWEP.PrintName          = "Russian Roulette"
   SWEP.Slot               = 6

   SWEP.ViewModelFlip      = false
   SWEP.ViewModelFOV       = 54

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "TBATBATBA"
   };

   SWEP.Icon = "vgui/ttt/icon_rus.png"
end

SWEP.Base                  = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP1
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

-- Changing SWEP above
SWEP.Category				= "Russian Roulette"
SWEP.PrintName				= "Russian Roulette"
SWEP.Author					= "jsw0244"
SWEP.Purpose				= "Left click : shoot \nRight click : throw"
SWEP.Spawnable	  			= true
SWEP.DrawAmmo				= false
SWEP.ViewModelFOV			= 55
SWEP.Slot					= 6
SWEP.SlotPos				= 0
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= false
SWEP.ViewModel				= "models/weapons/v_357.mdl"
SWEP.WorldModel				= "models/weapons/w_357.mdl"
SWEP.AutoSwitchTo	    	= true
SWEP.AutoSwitchFrom  		= true
SWEP.DrawCrosshair 			= false
SWEP.ViewModelFlip			= false
SWEP.Weight 				= 5
SWEP.AllowDrop 				= false

SWEP.UseHands				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.ShowWorldModel			= false
SWEP.MuzzleAttachment		= "1"
SWEP.ShellEjectAttachment	= "2"

SWEP.WElements = {
	["revolver"] = { type = "Model", model = "models/weapons/w_357.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.635, 1.557, -3.636), angle = Angle(10.519, 180, 180), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

local sound_next = Sound("vo/npc/male01/letsgo02.wav")
local sound_spin = Sound("weapons/357/357_spin1.wav")
local sound_shoot = Sound("weapons/357/357_fire3.wav")
local sound_empty = Sound("weapons/pistol/pistol_empty.wav")
local sound_reload = Sound("weapons/357/357_reload1.wav")
local sound_scream = Sound("vo/npc/male01/no02.wav")
local sound_preshot = {
	"vo/npc/male01/pain01.wav",
	"vo/npc/male01/pain02.wav",
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav"
}

function SpreadTheLove(ply, equipment, is_item)
	if equipment == "ttt_weapon_roulette" then
		GiveAllPlayers()
	end
end

function SWEP:draw3D2DHUD( )
	local vm = self.Owner:GetViewModel()
	local obj = vm:LookupAttachment( "muzzle" )
	local att = vm:GetAttachment( obj )
	local ang = self.Owner:EyeAngles()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), -90)

	local bullet = surface.GetTextureID("cw2/gui/bullet")
	cam.Start3D2D(att.Pos + ang:Forward() * -3 +ang:Up() * -4 + ang:Right() * 1, ang, 0.02)
		cam.IgnoreZ(true)
			ShadowText( 1-self:GetNWInt( "Order" ) .."/1", "CustomFont", 90, 80, 3, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			if self:GetNWInt( "Order" ) then
				surface.SetTexture( bullet )
				surface.SetDrawColor(0, 0, 0, 255)
				for i = 1, 6 do
					surface.DrawTexturedRectRotated(115, 38 + (i - 1) * 15, 30, 30, 180)
				end
				surface.SetTexture( bullet )
				surface.SetDrawColor(255, 255, 255, 255)
				for i = 1, 6-self:GetNWInt( "Order" ) do
					surface.DrawTexturedRectRotated(113, 38 + (i - 1) * 15 - 2, 30, 30, 180)
				end
			end
		cam.IgnoreZ(false)
	cam.End3D2D()
end

function SWEP:PostDrawViewModel()
	self:draw3D2DHUD()
end

function SWEP:Deploy()
	self:SetNextPrimaryFire( CurTime() + 0.7 )
	self:SetNextSecondaryFire( CurTime() + 0.7 )
    self:EmitSound( sound_spin )
	self:SendWeaponAnim( ACT_VM_DRAW )
end


function SWEP:PrimaryAttack()
	local ply = self.Owner
	self:SetNextPrimaryFire( CurTime() + 1 )
	ply:SetAnimation( PLAYER_ATTACK1 )

	if( 1 == math.random(1, 3) ) then
		local angle = self.Owner:EyeAngles()
		local att = self:GetAttachment( self:LookupAttachment( "muzzle" ) )
		local muzzle = EffectData()
		local blood = EffectData()
		angle.y = angle.y + 180
		angle.p = -angle.p

		muzzle:SetEntity( self.Weapon )
		muzzle:SetOrigin( self.Owner:GetShootPos() )
		muzzle:SetNormal( self.Owner:GetAimVector() )
		muzzle:SetAngles( angle )
		muzzle:SetAttachment( self.MuzzleAttachment )

		blood:SetOrigin( self.Owner:GetShootPos() )
		blood:SetMagnitude( 1 )
		blood:SetNormal( self.Owner:GetAimVector() )
		blood:SetAngles( angle )

		util.Effect( "MuzzleEffect", muzzle )
		util.Effect( "BloodImpact", blood )

		if SERVER then
			ply:EmitSound( sound_shoot )
			ply:EmitSound( sound_scream )
			ply:Kill()
			self:Remove()
		end
	else
		if SERVER then
			ply:EmitSound( sound_preshot[math.random(1, #sound_preshot)] )
			ply:EmitSound( sound_empty )
			self:Remove()
		end
	end
end

function GiveAllPlayers()

	for k, v in pairs(player.GetAll()) do

		if v:Alive() then

			v:Give("ttt_weapon_roulette")

			for x, y in pairs(v:GetWeapons()) do
				if y:GetPrintName() == "Russian Roulette" then
					print(y)
					v:SetActiveWeapon(y)
				end
			end

			v:EmitSound( sound_next )
		end
	end
end



function SWEP:Initialize()
	self:SetHoldType( "revolver" )
    self:SetNWInt( "Order", 0 )
    self:SetNWInt( "Win", math.random(0,5) )
	if CLIENT then
		self.VElements = table.FullCopy( self.VElements )
		self.WElements = table.FullCopy( self.WElements )
		self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

		self:CreateModels(self.VElements)
		self:CreateModels(self.WElements)

		if IsValid(self.Owner) then
			local vm = self.Owner:GetViewModel()
			if IsValid(vm) then
				self:ResetBonePositions(vm)
				if (self.ShowViewModel == nil or self.ShowViewModel) then
					vm:SetColor(Color(255,255,255,255))
				else
					vm:SetColor(Color(255,255,255,1))
					vm:SetMaterial("Debug/hsv")
				end
			end
		end
	end
end

function SWEP:Holster()
	return false
end

function SWEP:OnRemove()
	self:Holster()
end

hook.Add("TTTOrderedEquipment", "BoughtItem", SpreadTheLove)

if CLIENT then
	SWEP.vRenderOrder = nil
	function SWEP:ViewModelDrawn()

		local vm = self.Owner:GetViewModel()
		if !IsValid(vm) then return end

		if (!self.VElements) then return end

		self:UpdateBonePositions(vm)

		if (!self.vRenderOrder) then

			self.vRenderOrder = {}

			for k, v in pairs( self.VElements ) do
				if (v.type == "Model") then
					table.insert(self.vRenderOrder, 1, k)
				end
			end

		end

		for k, name in ipairs( self.vRenderOrder ) do

			local v = self.VElements[name]
			if (!v) then self.vRenderOrder = nil break end
			if (v.hide) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (!v.bone) then continue end

			local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

			if (!pos) then continue end

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			end
		end
	end

	SWEP.wRenderOrder = nil
	function SWEP:DrawWorldModel()
		if (self.ShowWorldModel == nil or self.ShowWorldModel) then
			self:DrawModel()
		end
		if (!self.WElements) then return end
		if (!self.wRenderOrder) then
			self.wRenderOrder = {}
			for k, v in pairs( self.WElements ) do
				if (v.type == "Model") then
					table.insert(self.wRenderOrder, 1, k)
				elseif (v.type == "Sprite" or v.type == "Quad") then
					table.insert(self.wRenderOrder, k)
				end
			end
		end
		if (IsValid(self.Owner)) then
			bone_ent = self.Owner
		else
			bone_ent = self
		end

		for k, name in pairs( self.wRenderOrder ) do
			local v = self.WElements[name]
			if (!v) then self.wRenderOrder = nil break end
			if (v.hide) then continue end

			local pos, ang

			if (v.bone) then
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
			else
				pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
			end

			if (!pos) then continue end

			local model = v.modelEnt
			local sprite = v.spriteMaterial

			if (v.type == "Model" and IsValid(model)) then

				model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)

				model:SetAngles(ang)
				//model:SetModelScale(v.size)
				local matrix = Matrix()
				matrix:Scale(v.size)
				model:EnableMatrix( "RenderMultiply", matrix )

				if (v.material == "") then
					model:SetMaterial("")
				elseif (model:GetMaterial() != v.material) then
					model:SetMaterial( v.material )
				end

				if (v.skin and v.skin != model:GetSkin()) then
					model:SetSkin(v.skin)
				end

				if (v.bodygroup) then
					for k, v in pairs( v.bodygroup ) do
						if (model:GetBodygroup(k) != v) then
							model:SetBodygroup(k, v)
						end
					end
				end

				if (v.surpresslightning) then
					render.SuppressEngineLighting(true)
				end

				render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
				render.SetBlend(v.color.a/255)
				model:DrawModel()
				render.SetBlend(1)
				render.SetColorModulation(1, 1, 1)

				if (v.surpresslightning) then
					render.SuppressEngineLighting(false)
				end
			end
		end
	end

	function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

		local bone, pos, ang
		if (tab.rel and tab.rel != "") then

			local v = basetab[tab.rel]

			if (!v) then return end

			// Technically, if there exists an element with the same name as a bone
			// you can get in an infinite loop. Let's just hope nobody's that stupid.
			pos, ang = self:GetBoneOrientation( basetab, v, ent )

			if (!pos) then return end

			pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
			ang:RotateAroundAxis(ang:Up(), v.angle.y)
			ang:RotateAroundAxis(ang:Right(), v.angle.p)
			ang:RotateAroundAxis(ang:Forward(), v.angle.r)

		else

			bone = ent:LookupBone(bone_override or tab.bone)

			if (!bone) then return end

			pos, ang = Vector(0,0,0), Angle(0,0,0)
			local m = ent:GetBoneMatrix(bone)
			if (m) then
				pos, ang = m:GetTranslation(), m:GetAngles()
			end

			if (IsValid(self.Owner) and self.Owner:IsPlayer() and
				ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
				ang.r = -ang.r // Fixes mirrored models
			end

		end

		return pos, ang
	end



	function SWEP:CreateModels( tab )

		if (!tab) then return end

		// Create the clientside models here because Garry says we can't do it in the render hook
		for k, v in pairs( tab ) do
			if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
					string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

				v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
				if (IsValid(v.modelEnt)) then
					v.modelEnt:SetPos(self:GetPos())
					v.modelEnt:SetAngles(self:GetAngles())
					v.modelEnt:SetParent(self)
					v.modelEnt:SetNoDraw(true)
					v.createdModel = v.model
				else
					v.modelEnt = nil
				end
			end
		end

	end

	local allbones
	local hasGarryFixedBoneScalingYet = false

	function SWEP:UpdateBonePositions(vm)

		if self.ViewModelBoneMods then

			if (!vm:GetBoneCount()) then return end
			local loopthrough = self.ViewModelBoneMods
			if (!hasGarryFixedBoneScalingYet) then
				allbones = {}
				for i=0, vm:GetBoneCount() do
					local bonename = vm:GetBoneName(i)
					if (self.ViewModelBoneMods[bonename]) then
						allbones[bonename] = self.ViewModelBoneMods[bonename]
					else
						allbones[bonename] = {
							scale = Vector(1,1,1),
							pos = Vector(0,0,0),
							angle = Angle(0,0,0)
						}
					end
				end

				loopthrough = allbones
			end

			for k, v in pairs( loopthrough ) do
				local bone = vm:LookupBone(k)
				if (!bone) then continue end

				local s = Vector(v.scale.x,v.scale.y,v.scale.z)
				local p = Vector(v.pos.x,v.pos.y,v.pos.z)
				local ms = Vector(1,1,1)
				if (!hasGarryFixedBoneScalingYet) then
					local cur = vm:GetBoneParent(bone)
					while(cur >= 0) do
						local pscale = loopthrough[vm:GetBoneName(cur)].scale
						ms = ms * pscale
						cur = vm:GetBoneParent(cur)
					end
				end

				s = s * ms

				if vm:GetManipulateBoneScale(bone) != s then
					vm:ManipulateBoneScale( bone, s )
				end
				if vm:GetManipulateBoneAngles(bone) != v.angle then
					vm:ManipulateBoneAngles( bone, v.angle )
				end
				if vm:GetManipulateBonePosition(bone) != p then
					vm:ManipulateBonePosition( bone, p )
				end
			end
		else
			self:ResetBonePositions(vm)
		end

	end

	function SWEP:ResetBonePositions(vm)

		if (!vm:GetBoneCount()) then return end
		for i=0, vm:GetBoneCount() do
			vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
			vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
			vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
		end

	end

	function table.FullCopy( tab )

		if (!tab) then return nil end

		local res = {}
		for k, v in pairs( tab ) do
			if (type(v) == "table") then
				res[k] = table.FullCopy(v) // recursion ho!
			elseif (type(v) == "Vector") then
				res[k] = Vector(v.x, v.y, v.z)
			elseif (type(v) == "Angle") then
				res[k] = Angle(v.p, v.y, v.r)
			else
				res[k] = v
			end
		end

		return res

	end

end
