local function checkStackpos(item, position)
	position.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE

	local thing = getThingFromPos(position)
	position.stackpos = STACKPOS_TOP_FIELD

	local field = getThingFromPos(position)
	return (item.uid ~= thing.uid and (thing.itemid >= 100 or field.itemid ~= 0))
end

function onUse(cid, item, fromPosition, itemEx, toPosition)
	if(getItemLevelDoor(item.itemid) > 0) then
		if(item.actionid == 189) then
			if(isPremium(cid) ~= TRUE) then
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
				return TRUE
			end

			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
			return TRUE
		end

		local gender = item.actionid - 186
		if(gender == PLAYERSEX_FEMALE or gender == PLAYERSEX_MALE or gender == PLAYERSEX_GAMEMASTER) then
			local playerGender = getPlayerSex(cid)
			if(playerGender ~= gender) then
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
				return TRUE
			end

			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
			return TRUE
		end

		local skull = item.actionid - 180
		if(skull >= 0 and skull < 6) then
			local playerSkull = getCreatureSkullType(cid)
			if(playerSkull ~= skull) then
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
				return TRUE
			end

			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
			return TRUE
		end

		local group = item.actionid - 150
		if(group >= 0 and group < 30) then
			local playerGroup = getPlayerGroupId(cid)
			if(playerGroup < group) then
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
				return TRUE
			end

			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
			return TRUE
		end

		local vocation = item.actionid - 100
		if(vocation >= 0 and vocation < 50) then
			local playerVocationInfo = getVocationInfo(getPlayerVocation(cid))
			if(playerVocationInfo.id ~= vocation and playerVocationInfo.fromVocation ~= vocation) then
				doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
				return TRUE
			end

			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
			return TRUE
		end

		if(item.actionid == 200 or (item.actionid ~= 0 and getPlayerLevel(cid) >= (item.actionid - getItemLevelDoor(item.itemid)))) then
			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
		else
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "Only the worthy may pass.")
		end

		return TRUE
	end

	if(isInArray(specialDoors, item.itemid) == TRUE) then
		if(item.actionid == 200 or (item.actionid ~= 0 and getPlayerStorageValue(cid, item.actionid) > 0)) then
			doTransformItem(item.uid, item.itemid + 1)
			doTeleportThing(cid, toPosition, TRUE)
		else
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "The door seems to be sealed against unwanted intruders.")
		end

		return TRUE
	end

	if(isInArray(keys, item.itemid) == TRUE) then
		if(itemEx.actionid > 0) then
			if(item.actionid == itemEx.actionid and doors[itemEx.itemid] ~= nil) then
				doTransformItem(itemEx.uid, doors[itemEx.itemid])
				return TRUE
			end

			doPlayerSendCancel(cid, "The key does not match.")
			return TRUE
		end

		return FALSE
	end

	if(isInArray(horizontalOpenDoors, item.itemid) == TRUE and checkStackpos(item, fromPosition)) then
		local newPosition = toPosition
		newPosition.y = newPosition.y + 1
		local doorPosition = fromPosition
		doorPosition.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE
		local doorCreature = getThingfromPos(doorPosition)
		if(doorCreature.itemid ~= 0) then
			if(getTileInfo(doorPosition).protection and not getTileInfo(newPosition).protection and doorCreature.uid ~= cid) then
				doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
			else
				doTeleportThing(doorCreature.uid, newPosition, TRUE)
				if(isInArray(closingDoors, item.itemid) ~= TRUE) then
					doTransformItem(item.uid, item.itemid - 1)
				end
			end

			return TRUE
		end

		doTransformItem(item.uid, item.itemid - 1)
		return TRUE
	end

	if(isInArray(verticalOpenDoors, item.itemid) == TRUE and checkStackpos(item, fromPosition)) then
		local newPosition = toPosition
		newPosition.x = newPosition.x + 1
		local doorPosition = fromPosition
		doorPosition.stackpos = STACKPOS_TOP_MOVEABLE_ITEM_OR_CREATURE
		local doorCreature = getThingfromPos(doorPosition)
		if(doorCreature.itemid ~= 0) then
			if(getTileInfo(doorPosition).protection and not getTileInfo(newPosition).protection and doorCreature.uid ~= cid) then
				doPlayerSendDefaultCancel(cid, RETURNVALUE_NOTPOSSIBLE)
			else
				doTeleportThing(doorCreature.uid, newPosition, TRUE)
				if(isInArray(closingDoors, item.itemid) ~= TRUE) then
					doTransformItem(item.uid, item.itemid - 1)
				end
			end

			return TRUE
		end

		doTransformItem(item.uid, item.itemid - 1)
		return TRUE
	end

	if(doors[item.itemid] ~= nil and checkStackpos(item, fromPosition)) then
		if(item.actionid == 0) then
			doTransformItem(item.uid, doors[item.itemid])
		else
			doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "It is locked.")
		end

		return TRUE
	end

	return FALSE
end
