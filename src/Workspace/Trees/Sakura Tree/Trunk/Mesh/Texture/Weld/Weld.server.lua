--Auto welding script (anchors so the tree doesnt fall apart)

for i,v in pairs(script.Parent:GetDescendants()) do
	if v.Name ~= "Handle" and v:IsA("Part") or v:IsA("WedgePart") or v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("TrussPart") then
		local Weld = Instance.new("WeldConstraint",v)
		Weld.Part0 = script.Parent.Handle
		Weld.Part1 = v
	end
end
                                                                                                                                                                                                                                                                                    