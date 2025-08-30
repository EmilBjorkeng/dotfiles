local ns_id = vim.api.nvim_create_namespace("Git-Phantom-Line")

local M = {}

-- Calculate similarity between two strings (Between 0.0 and 1.0)
local function calculate_similarity(str1, str2)
    if str1 == str2 then return 1.0 end
    if str1 == "" or str2 == "" then return 0.0 end

    -- Check if one starts or ends with the other
    -- Example just added a comment char to the front
    -- Good for short lines that would fail otherwise
    local long_str = #str1 > #str2 and vim.trim(str1) or vim.trim(str2)
    local short_str = #str1 > #str2 and vim.trim(str2) or vim.trim(str1)
    -- Long string starts with short string
    if long_str:sub(1, #short_str) == short_str then return 1.0 end
    -- Long string ends with short string
    if long_str:sub(-#short_str) == short_str then return 1.0 end

    -- Character-based similarity
    local function char_similarity(s1, s2)
        local longer = #s1 > #s2 and s1 or s2
        local shorter = #s1 > #s2 and s2 or s1

        local matches = 0
        local shorter_chars = {}

        -- Count character frequencies in the shorter string
        for i = 1, #shorter do
            local char = shorter:sub(i, i)
            shorter_chars[char] = (shorter_chars[char] or 0) + 1
        end

        -- Count matches in longer string
        for i = 1, #longer do
            local char = longer:sub(i, i)
            if shorter_chars[char] and shorter_chars[char] > 0 then
                matches = matches + 1
                shorter_chars[char] = shorter_chars[char] - 1
            end
        end

        return matches / #longer
    end

    -- Word-based similarity
    local function word_similarity(s1, s2)
        local words1 = {}
        local words2 = {}

        for word in s1:gmatch("%w+") do
            words1[word] = (words1[word] or 0) + 1
        end

        for word in s2:gmatch("%w+") do
            words2[word] = (words2[word] or 0) + 1
        end

        local common_words = 0
        local total_unique = 0

        -- Count all unique words
        local all_words = {}
        for word in pairs(words1) do all_words[word] = true end
        for word in pairs(words2) do all_words[word] = true end
        for _ in pairs(all_words) do total_unique = total_unique + 1 end

        -- Count common words
        for word in pairs(words1) do
            if words2[word] then
                common_words = common_words + 1
            end
        end

        return total_unique > 0 and common_words / total_unique or 0
    end

    -- Structure similarity
    local function structure_similarity(s1, s2)
        local structure1 = s1:gsub("%w+", "WORD"):gsub("%d+", "NUM"):gsub("%s+", " ")
        local structure2 = s2:gsub("%w+", "WORD"):gsub("%d+", "NUM"):gsub("%s+", " ")

        if structure1 == structure2 then return 0.5 end -- Boost for same structure
        return 0
    end

    local char_sim = char_similarity(str1, str2)
    local word_sim = word_similarity(str1, str2)
    local struct_sim = structure_similarity(str1, str2)

    -- Weighted combination
    return char_sim * 0.4 + word_sim * 0.4 + struct_sim * 0.2
end

local function classify_with_similarity(removed_lines, added_lines)
    local similarity_threshold = 0.6

    local used_added = {}
    local lines_removed = {}
    local lines_added = {}
    local lines_modified = {}

    -- Try to match each removed line with an added line
    for removed_index, removed in ipairs(removed_lines) do
        local best_match = nil
        local best_similarity = 0
        local best_index = nil

        for i, added in ipairs(added_lines) do
            if not used_added[i] then
                local similarity = calculate_similarity(removed, added)
                if similarity > best_similarity then
                    best_similarity = similarity
                    best_match = added
                    best_index = i
                end
            end
        end

        -- If similarity is above threshold, it's a change
        if best_similarity >= similarity_threshold then
            -- print('Modified', best_match, best_index)
            table.insert(lines_modified, best_index)
            if best_index ~= nil then
                used_added[best_index] = true
            end
        else
            -- print('Removed', removed, removed_index)
            table.insert(lines_removed, removed_index)
        end
    end

    -- Add remaining additions
    for i,_ in ipairs(added_lines) do
        if not used_added[i] then
            -- print('Added', added, i)
            table.insert(lines_added, i)
        end
    end

    local filtered_removed = {}
    local i = 1
    while i <= #lines_removed do
        local start = lines_removed[i]
        -- skip all consecutive lines
        while i + 1 <= #lines_removed and lines_removed[i + 1] == lines_removed[i] + 1 do
            i = i + 1
        end
        table.insert(filtered_removed, start)

        i = i + 1
    end

    return lines_modified, filtered_removed, lines_added
end

local function manage_segment(line_status, removed_lines, added_lines, new_start)
    local modified_lines = {}
    modified_lines, removed_lines, added_lines =
        classify_with_similarity(removed_lines, added_lines)

    for _,v in ipairs(modified_lines) do
        line_status[v + new_start - 1] = 'modified'
    end
    for _,v in ipairs(added_lines) do
        line_status[v + new_start - 1] = 'added'
    end
    for _,v in ipairs(removed_lines) do
        -- Counts the amount of added above the current remove
        -- To counteract the moving down this would do
        local count = 0
        for _,added_v in ipairs(added_lines) do
            if added_v > v then
                break
            end
            count = count + 1
        end
        local line_num = v + new_start - 1 - count

        local shared_sign = line_status[line_num]
        if shared_sign == nil then shared_sign = ''
        elseif shared_sign == 'deleted' then return         -- Edge case where there is a double deleted
        elseif string.find(shared_sign, "_") then return    -- Edge case where there already is a shared sign there
        else shared_sign = '_' .. shared_sign end

        line_status[line_num] = 'deleted' .. shared_sign
    end
end

function M.get_git_diff()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
        return {}
    end

    -- Clear Phantom lines
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

    -- Get diff to see added/removed lines
    local diff_cmd = "git diff --unified=0 " .. vim.fn.shellescape(filepath)
    local diff_output = vim.fn.system(diff_cmd)

    if diff_output == "" then
        return {}
    end

    local line_status = {}

    local old_start, old_count
    local new_start, new_count

    local removed_lines = {}
    local added_lines = {}

    -- Loop over all lines from diff_output
    for line in diff_output:gmatch("[^\r\n]+") do

        -- Skip over the three longs at the start
        local first_three = line:sub(0,3)
        if first_three == '---' or first_three == '+++' then
            goto continue
        end

        -- Hunk header: @@ -old_start,old_count +new_start,new_count @@
        local old_s, old_c, new_s, new_c = line:match("^@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
        if old_s then
            -- Manage last section
            manage_segment(line_status, removed_lines, added_lines, new_start)

            -- Start a new section
            removed_lines = {}
            added_lines = {}

            old_start = tonumber(old_s)
            old_count = tonumber(old_c) or 0
            new_start = tonumber(new_s)
            new_count = tonumber(new_c) or 0
        else
            -- Gather data for section
            local first = line:sub(0,1)
            if first == '-' then
                table.insert(removed_lines, line:sub(2))
            elseif first == '+' then
                table.insert(added_lines, line:sub(2))
            end
        end
        ::continue::
    end
    -- For the last segment
    manage_segment(line_status, removed_lines, added_lines, new_start)

    return line_status
end

return M
