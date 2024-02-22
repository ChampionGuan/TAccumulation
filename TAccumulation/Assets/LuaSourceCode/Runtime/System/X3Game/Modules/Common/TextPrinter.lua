---------------------------------------------------------------------
-- Client (C) CompanyName, All Rights Reserved
-- Created by: AuthorName
-- Date: 2020-01-06 11:50:12
---------------------------------------------------------------------

-- To edit this template in: Data/Config/Template.lua
-- To disable this template, check off menuitem: Options-Enable Template File

---@class TextPrinter
local TextPrinter = class("TextPrinter")
local RichTextBeginFlags={"<b>","<i>","<size=","<color="}
local RichTextEndFlags={"</b>","</i>","</size>","</color>"}

local function StringToTable(str)
	str = not str and "" or str;
	local result ={}
	local lenInByte = #str
	local count = 0
	local i = 1
	while true do
		local curByte = string.byte(str, i)
		if i > lenInByte then
			break
		end
		local byteCount = 1
		if curByte > 0 and curByte < 128 then
			byteCount = 1
		elseif curByte>=128 and curByte<224 then
			byteCount = 2
		elseif curByte>=224 and curByte<240 then
			byteCount = 3
		elseif curByte>=240 and curByte<=247 then
			byteCount = 4
		else
			break
		end

		table.insert(result,#result+1,string.sub(str,i,i+byteCount-1))
		i = i + byteCount
		count = count + 1
	end
	return result;
end

local function getText(mTable,beginIndex)
	local mText = ""
	local mEndIndex = -1
	for i=beginIndex,#mTable do
		mText = mText..mTable[i]
		if mTable[i] == ">" then
			mEndIndex = i
			break
		end
	end
	return mText,mEndIndex
end

local function addTable(mTable,mStr,mFlag,otherStr)
	table.insert(mTable,#mTable+1,
		{
			value=mStr,
			flag=mFlag,--  代表正常字符，0代表开始显示富文本，1代表富文本结束
			otherValue = otherStr
		})
end

local function isInRichTextBeginFlags(strCode)
	for i=1,#RichTextBeginFlags do
		local mIndex = string.find(strCode,RichTextBeginFlags[i])
		if mIndex ~= nil then
			return true,i
		end
	end
	return false
end

local function isInRichTextEndFlags(strCode)
	for i=1,#RichTextEndFlags do
		local mIndex = string.find(strCode,RichTextEndFlags[i])
		if mIndex ~= nil then
			return true,i
		end
	end
	return false
end

local function formationBBCode(mSourceTable,beginIndex,mResult)
	local mendindex = 0
	local mstr=""

	local mText,mendindex = getText(mSourceTable,beginIndex)

	local ishasInBegin,flagindex= isInRichTextBeginFlags(mText)

	if ishasInBegin then
		addTable(mResult,mText,0,RichTextEndFlags[flagindex])
		return true,mendindex
	end

	local ishasInend,flagindex = isInRichTextEndFlags(mText)

	if ishasInend then
		addTable(mResult,mText,1)
		return true,mendindex
	end

	return false
end

local function FormationTableStr(mTable)
	local result = {}

	local i = 1

	while true do
		if i > #mTable then
			break
		end

		if mTable[i]=="<" then
			local bresult,continueIndex = formationBBCode(mTable,i,result)
			if bresult then
				i = continueIndex+1
			else
				addTable(result,mTable[i],-1)
				i=i+1
			end
		else
			addTable(result,mTable[i],-1)
			i=i+1
		end
	end
	return result
end

local function GetAllBeginFlag(mTable,index,mstring,motherstring)

	local currentData = mTable[index]

	if currentData == nil then
		return mstring
	end

	if currentData.flag == 0 then
		mstring = mstring..currentData.value
		motherstring = currentData.otherValue..motherstring
		index = index+1
		return GetAllBeginFlag(mTable,index,mstring,motherstring)
	elseif currentData.flag == 1 then
		mstring = mstring..currentData.value
		index = index+1
		return GetAllBeginFlag(mTable,index,mstring,motherstring)
	else
		mstring = mstring..currentData.value
		return index,mstring,motherstring
	end
end


local function mergeFlag(mTable)
	local mresult ={}

	local i = 1

	while true do
		if i > #mTable then
			break
		end

		if mTable[i].flag == 0 then
			local mind,str,ostr = GetAllBeginFlag(mTable,i,"","")
			addTable(mresult,str,mTable[i].flag,ostr)
			i =mind+1
		elseif mTable[i].flag == 1 then
			local mind,str,ostr = GetAllBeginFlag(mTable,i,"","")
			addTable(mresult,str,mTable[i].flag,ostr)
			i =mind+1
		else
			table.insert(mresult,#mresult+1,mTable[i])
			i = i+1
		end
	end

	return mresult
end

local function GetPrintStr(mstr)

	local strToTable = StringToTable(mstr)
	--print("=======strToTable===========",#strToTable)
	local formation = FormationTableStr(strToTable)
	--print("=======formation===========",#formation)
	local result = mergeFlag(formation)
	--print("=======mergeFlag===========",#result)
	return result
end


function TextPrinter:Print(mStr,speed,OnUpdateCallBack,onFinishCallBack)

	--print("=======传入的文字===========",mStr)
	local mstrTable = self:OpreationStr(mStr)

	if mstrTable == nil then
		if onFinishCallBack ~= nil then
			onFinishCallBack()
		end
		
		return
	end
	
	--print("=======处理后文字个数===========",#mstrTable)

	local TotalTime = #mstrTable * speed
	local begin = 1
	local To = #mstrTable

	local currentIndex = 0
	local currentStr =""
	self.printTween = CS.DG.Tweening.DOTween.To(function(x) begin = x end, begin, To, TotalTime);
	--self.printTween:SetDelay(2);
	self.printTween:SetEase(CS.DG.Tweening.Ease.Linear);
	local mOtherValue = ""
	self.printTween:OnUpdate(function()
			if currentIndex < math.floor(begin)  then
				currentIndex = math.floor(begin)
				if OnUpdateCallBack ~= nil then
					if mstrTable[currentIndex].flag == 0 then
						mOtherValue = mstrTable[currentIndex].otherValue
					elseif mstrTable[currentIndex].flag == 1 then
						mOtherValue = ""
					end

					currentStr = currentStr..mstrTable[currentIndex].value
					
					--print("=======打出的文字===========",currentStr)
					OnUpdateCallBack(currentStr..mOtherValue)
				end
			end
		end);

	self.printTween:OnComplete(function()

			if onFinishCallBack ~= nil then
				self.printTween=nil
				onFinishCallBack()
			end

		end);
	
	return self.printTween
end

function TextPrinter:EndPrint()
	if self.printTween then
		self.printTween:Kill(false)
		self.printTween = nil
	end
end

function TextPrinter:OpreationStr(mStr)
	if mStr == nil then
		return nil
	end
	--local ss = "avbdr<color=#ff1212>哈哈</color>，你好.A~！@#%%%））））---==-=- hello 1235660"
	local mTable = GetPrintStr(mStr)

	return mTable
end


return TextPrinter