AddCSLuaFile()
include("lib/shadow_text.lua")

ENT.Type 				= "anim"
ENT.PrintName			= "entity_roulette"
ENT.Author				= "jsw0244"
ENT.Contact				= ""
ENT.Purpose				= ""
ENT.Instructions		= ""
ENT.Spawnable			= false
ENT.AdminOnly 			= true 
ENT.displayDistance     = 256
	
function ENT:Initialize()
	if SERVER then
		self:SetNWInt( "Order", 0 ) 
		self:SetNWInt( "Win", math.random(0,5) ) 
		self:SetModel( "models/weapons/w_357.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE ) 

		local Phys = self:GetPhysicsObject()
		if Phys:IsValid() then
			Phys:Wake()
		end
	end 
end

function ENT:Use( activator, caller ) 
	if activator:IsPlayer() then
		if activator:GetWeapon( "weapon_roulette" ) == NULL then
			activator:Give( "weapon_roulette" )
			local roulette = activator:GetWeapon( "weapon_roulette" )
			if IsValid( roulette ) then
				activator:SetActiveWeapon( roulette ) 
				activator:GetActiveWeapon():Deploy()
				roulette:SetNWInt( "Order", self:GetNWInt( "Order" ) ) 
				roulette:SetNWInt( "Win", self:GetNWInt( "Win" ) )
			end
			self.Entity:Remove()
		end
	end
end
	
if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		local ply = LocalPlayer()
		
		if ply:GetPos():Distance(self:GetPos()) > self.displayDistance then
			return
		end
		
		local eyeAng = EyeAngles()
		eyeAng.p = 0
		eyeAng.y = eyeAng.y - 90
		eyeAng.r = 90
		local bullet = surface.GetTextureID("cw2/gui/bullet")
		cam.Start3D2D(self:GetPos() + self:GetForward() * 7 + Vector(0,0,7.5), eyeAng, 0.05)
			ShadowText( "E to pick up", "CustomFont", 0, -90, 3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			ShadowText( 6-self:GetNWInt( "Order" ) .."/6", "CustomFont", 0, 0, 3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			if self:GetNWInt( "Order" ) then
				surface.SetTexture(bullet)
				surface.SetDrawColor(0, 0, 0, 255)
				for i = 1, 6 do
					surface.DrawTexturedRectRotated(77, -28 + (i - 1) * 12, 25, 25, 180)
				end
				surface.SetTexture( bullet )
				surface.SetDrawColor(255, 255, 255, 255)
				for i = 1, 6-self:GetNWInt( "Order" ) do
					surface.DrawTexturedRectRotated(75, -28 + (i - 1) * 12 - 2, 25, 25, 180)
				end
			end
		cam.End3D2D()
	end
end