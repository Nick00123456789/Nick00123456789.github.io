--[[
  Library with some things related to make massive lists easier.

  To use, include with `local virtualizing = require('shared/ui/virtualizing')` and then call `virtualizing.List(…)`.
]]

local virtualizing = {}

---Renders large (up to 10k) lists of items. Takes a reference to the collection and a function that will be called for
---each item to render it on the screen, and returns a function which, when called, would draw the elements. If source
---collection has changed, call the returned function with `'refresh'` parameter to signal that recomputation is needed.
---
---Each item will be measured with its height stored for accurate scrolling.Note: if your list is more like 100k items, 
---consider using a fixed size for each item instead and just do a simple loop.
---@generic TSource
---@param source TSource[] @Source collection.
---@param render fun(item: TSource) @Function that will be called for each item to draw it on the screen.
---@return fun(param: string?) @Function for rendering the list. Alternatively, call it with `'refresh'` argument to refresh the list.
function virtualizing.List(source, render)
  return virtualizing.WrappedList(source, nil, render)
end

---Renders large (up to 10k) lists of items with a function that can do some precomputation and convert items into something
---else (like parsing a line of text into a bunch of words). Takes a reference to the collection, a function that will be called
---for each item to get its wrapped version and a function that will be called for each item to render it on the screen, and 
---returns a function which, when called, would draw the elements. If source collection has changed, call the returned function 
---with `'refresh'` parameter to signal that recomputation is needed.
---
---Each item will be measured with its height stored for accurate scrolling.Note: if your list is more like 100k items, 
---consider using a fixed size for each item instead and just do a simple loop.
---@generic TSource
---@generic TWrapped
---@param source TSource[] @Source collection.
---@param wrapper nil|fun(item: TSource): TWrapped @Wrapping function turning item into its wrapped version.
---@param render fun(item: TWrapped) @Function that will be called for each item to draw it on the screen.
---@return fun(param: string?) @Function for rendering the list. Alternatively, call it with `'refresh'` argument to refresh the list.
function virtualizing.WrappedList(source, wrapper, render)
	local lastWidth, lastOffset, lastSkip = 0, -1, 0
	local measuredHeight, measuredCount = 0, 0
	local cache = setmetatable({}, { __mode = 'kv' })
	local items = {}
	local processingNext = 1
	local scrolledToBottom, scrollToBottom = false, 0

	local function findFirstItem(item, _, offset)
		return item.startsAt > offset
	end

	return function (arg)
		if arg == 'refresh' then
			processingNext = 1
			scrollToBottom = scrolledToBottom and 3 or 0
			return
		end

		if processingNext > 0 then
			local totalCount = #source
			local leftToCreate = 20
			local testForRemoved = true
			while processingNext <= totalCount do
				local raw = source[processingNext]
				local cached = cache[raw]
				if not cached then
					cached = wrapper and wrapper(raw) or raw
					cache[raw] = cached
					leftToCreate = leftToCreate - 1
					if leftToCreate == 0 then
						break
					end
				end
				local existing = items[processingNext]
				if not existing or existing.wrapped ~= cached then
					local next = testForRemoved and items[processingNext + 1]
					if next and next.wrapped == cached then
						table.remove(items, processingNext)
						if existing.height >= 0 then
							for i = processingNext, #items do
								items[i].startsAt = items[i].startsAt - existing.height
							end
							scrollToBottom = 0
						end
					else
						items[processingNext] = { wrapped = cached, height = -1, startsAt = 0 }
					end
					testForRemoved = false
				end
				processingNext = processingNext + 1
			end
			if processingNext > totalCount then
				while #items > #source do
					table.remove(items, #items)
				end
				processingNext = 0
			end
		end

		local width = ui.windowWidth()
		if width ~= lastWidth then
			for i = 1, #items do
				items[i].height = -1
			end
			lastWidth = width
		end

		local offset = ui.getScrollY()
		local renderUntil = offset + ui.windowHeight()
		local leftToMeasure = 100

		local count = #items
		local lastItem = items[count]
		local skip = lastItem.startsAt == 0 and 1 or lastOffset == offset and lastSkip
			or math.max(1, table.findLeftOfIndex(items, findFirstItem, offset))
		if lastItem.startsAt > 0 and lastOffset ~= offset then
			lastOffset, lastSkip = offset, skip
		end

		ui.setCursorY(items[skip].startsAt)
		for i = skip, count do
			local item = items[i]
			local needsMeasure = item.height == -1
			if needsMeasure or item.startsAt + item.height > offset and item.startsAt < renderUntil then
				local pos = needsMeasure and ui.getCursorY() or 0
        if needsMeasure or ui.areaVisibleY(item.height) then
				  render(item.wrapped)
        else
          ui.offsetCursorY(item.height)
        end
				if needsMeasure then
					item.height = ui.getCursorY() - pos
					item.startsAt = pos
					measuredHeight, measuredCount = measuredHeight + item.height, measuredCount + 1
					leftToMeasure = leftToMeasure - 1
					if leftToMeasure == 0 then
						ui.setCursorY(measuredHeight / measuredCount * #source)
						break
					end
				end
			elseif lastItem.height ~= -1 then
				break
			else
				ui.offsetCursorY(item.height)
			end
		end

		ui.setCursorY(lastItem.startsAt + lastItem.height)
		if processingNext ~= 0 and measuredCount > 0 then
			ui.setCursorY(measuredHeight / measuredCount * #source)
		elseif processingNext == 0 and scrollToBottom > 0 then
			ui.setScrollY(ui.getScrollMaxY())
			scrollToBottom = scrollToBottom - 1
		end

		scrolledToBottom = offset == ui.getScrollMaxY()
	end
end

return virtualizing