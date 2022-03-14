--Made by Zaid 2021 (azaidrahman@gmail.com)

--SETTINGS
pipe_from_others    = false               -- Piping previous input from others into current question ( true / false )           
jump_if_only_one    = false              -- Autocode the answer if theres only one and jump into next question (if true enter the page id inside PAGES_ID) ( true / false )           
term_if_only_others = false               -- Terminate if theres only others answered ( true / false )
push_others_next    = false              -- Current Others being specified will be considered as answer for next question and can be autocoded ( true / false )      
PIPE_TYPE           = 0                  -- Refer to PIPE_TYPE below to associate what function you want to apply in current question         
pipe_row            = false               -- If you are piping to current table, are you piping to row? if yes Refer NOTE 1.0 ( true / false )
pipe_column         = false              -- If you are piping to current table, are you piping to column? if yes Refer NOTE 1.0 ( true / false )
from_grid           = false              -- Can ignore for now
-- grid_pipe_from_others   = false       -- Piping previous input from others into current question ( true / false )           
-- MAX_SEQ             = 99              -- Maximum number of possible sequence, for example 99 is none of the above, thus it is max (not important yet)

-- NOTE: CHECKBOX/RADIO = MCQ
-- PIPE_TYPE = {
--     ["MCQ -> MCQ"]     = 0, #DONE
--     ["MCQ -> grid"]    = 1, #DONE
--     ["grid -> grid"]   = 2, 
--     ["grid -> MCQ"]    = 3,
-- 	   ["sandbox"]       = 99,
-- }

PAGES_ID = [[
    next 46
    current auto
    thankyou 2
    terminate 3
]]


function main()
    -- NOTE 1.0: IF PIPING GRID, BY DEFAULT source_id REFERS TO THE ROWS, IF YOU WANT TO PIPE INTO COLUMNS, PUT ID IN SECONDARY_SOURCE_ID
    
    -- VARIABLES
    -- TODO: if only referencing column, default into source_id, then if both row and column only then use secondary
    source_id           = {221} 
    target_id           = {118}
    secondary_source_id = {}

    ------------------------------------------------------------
    
    pages = page_maker()
    
    current_question_types = question_type_func(pages["current"])

    -- if next(array_intersect(target_id,current_question_types["TABLE"])) ~= nil then
    --     pipe_from_others    = false                         
    --     jump_if_only_one    = false                   
    --     term_if_only_others = false
    -- end

    
    -- TODO turn this into for loop and if PIPE_TYPE inside of it to avoid repetition
    if PIPE_TYPE == 0 then 
        for i,s_id in ipairs(source_id) do
            for i2,t_id in ipairs(target_id)do
                pipe_mcq_to_mcq(pages, s_id, t_id, from_grid)
            end
        end

    elseif PIPE_TYPE == 1 then
        if next(source_id) ~= nil then 
            for i,s_id in ipairs(source_id) do
                for i2,t_id in ipairs(target_id)do
                    pipe_mcq_to_grid(pages, s_id, secondary_source_id[i], t_id, pipe_row, pipe_column)
                end
            end
        else
            for i,s_id in ipairs(secondary_source_id) do
                for i2,t_id in ipairs(target_id)do
                    pipe_mcq_to_grid(pages, nil, s_id, t_id, pipe_row, pipe_column)
                end
            end
        end
	elseif PIPE_TYPE == 99 then
		for i,s_id in ipairs(source_id) do
            for i2,t_id in ipairs(target_id)do
                sandbox(pages, s_id, secondary_source_id[i], t_id)
            end
        end
    end

end

-- CONSTANTS
EXCLUDE_OPTIONS = {             
    ["others"] = '97',                              
    ["all"]    = '98',                              
    ["none"]   = '99'                               
}

MAIN_QUESTION_TYPES = {
    "CHECKBOX","RADIO","TABLE","RANK"
}

------------------------------------

function sandbox(pages, row_source_id, column_source_id, target_id)
    return
end

--TODO: make a function to check for others, try to make it more rigorous and reusable
function pipe_mcq_to_mcq(pages, source_id, target_id, from_grid)
    if type(source_id) ~= 'number' or type(target_id) ~= 'number' then return end
    
    source_type = type(getvalue(source_id))
    source_answer = {}
    target_options = getquestionoptions(target_id, "Reporting")
    if pipe_from_others == false then target_title = getquestionoptions(target_id, "Title") end
    
    autocode_answers = {}
    others_answer = nil
    others_key = nil
    
    --SEPARATE OTHERS TO RESOLVE EDGE CASE OF OTHERS BEING A NUMBER AND CONSIDERED AS REPORTING VALUE
    --TODO: turn this into a function to reuse
    if source_type == "table" then 
        source_answer = getvalue(source_id)
        for k,v in pairs(source_answer)do
            -- IF SOURCE IS FROM A RAW OTHERS INPUT
            if string.find(k,"other") then
                others_answer = v
                others_key = string.gsub(k,"-other","")
                source_answer[k] = nil
            -- IF SOURCE IS FROM A PIPED OTHERS
            elseif string.find(k,[[id=]]) then
                others_answer = v
                source_answer[k] = nil
            -- TODO check why
            elseif  v == EXCLUDE_OPTIONS['others'] then
                source_answer[k] = nil
            end
        end
    else
        source_title = string.lower(getvaluelabel(source_id))
        if string.find(source_title,"^other") then
            others_answer = getvalue(source_id)
        end
        table.insert(source_answer,getvalue(source_id)) --IF ITS ONLY 1 OTHERS, TERMINATE_IxF_ONLY_OTHERS ALREADY TAKES CARE OF THIS
    end
    
    -- IF THERES ONLY 1 OTHERS FROM A RADIO BUTTON, THEN SEND TO TERMINATE IF SETTING "term_if_only_others" is true
    terminate_if_only_others(source_id, others_answer, source_answer, pages)

    -- LOOP THROUGH ALL THE OPTIONS, ESSENTIALLY HIDE ALL OPTIONS AND UNHIDE IF PASS CONDITIONS
    for key,reporting_value in pairs(target_options)do
        
        hideoption(target_id, reporting_value, true)
        
        if in_array(reporting_value, source_answer) then
            
            hideoption(target_id, reporting_value, false)

            -- AUTOCODE THE ANSWERS BESIDE "NONE"
            if reporting_value ~= EXCLUDE_OPTIONS["none"] then
                if pipe_from_others == false
                and reporting_value == EXCLUDE_OPTIONS["others"] then
                    
                    break
                else
                    autocode_answers[key] = reporting_value
                    
                end
            end
        end

        -- In case of others
        if ((pipe_from_others == true and reporting_value == EXCLUDE_OPTIONS["others"] and others_answer ~= nil) 
            or (pipe_from_others == false and reporting_value == EXCLUDE_OPTIONS["others"] and string.find(string.lower(target_title[key]),"other") and from_grid == false)) then
                hideoption(target_id, reporting_value, false)
        end

        if reporting_value == EXCLUDE_OPTIONS["none"] then hideoption(target_id, reporting_value, false) end
    end

    --JUMP WHEN THERES ONLY ONE
    --TODO: could probably turn this into a function
    if jump_if_only_one == true and count(autocode_answers) == 1 then
        if in_array(target_id,current_question_types["CHECKBOX"]) then
            setvalue(target_id,autocode_answers)
            jumptopage(pages["next"])
        else
            for k,v in pairs(autocode_answers)do
                setvalue(target_id,v)
            end
            jumptopage(pages["next"])
        end
    end
end

function pipe_mcq_to_grid(pages, row_source_id, column_source_id, target_id, is_target_rows, is_target_column)
    
    if (type(row_source_id) ~= 'number' or type(column_source_id) ~= 'number') and type(target_id) ~= 'number' then return end

    target_options = array_flip(gettablequestiontitles(target_id))
    others_answered = false

    autocode_answers = {}
    source_answer = {}
    sec_source_answer = {}
    source_answer_label = {}
    sec_source_answer_label = {}

    
	if row_source_id then source_answer,source_answer_label = source(row_source_id,source_answer,source_answer_label) end
    if column_source_id then sec_source_answer,sec_source_answer_label = source(column_source_id,sec_source_answer,sec_source_answer_label) end

    --------------------------------------------------------------------

    for row_title,row_id in pairs(target_options)do
        if is_target_rows then
            row_title = strip(row_title)
            hidequestion(row_id,true)
            if in_array(row_title,source_answer_label) then
                hidequestion(row_id,false)
            end

            if string.find(row_title,[[id=]]) and others_answered == true then
                hidequestion(row_id,false)
            end
        end
        --TODO: make an array of id's of rows that passed 
        if is_target_column then
            pipe_mcq_to_mcq(pages, column_source_id, row_id, true)
        end
    end

    

end

--IF ITS ONLY OTHERS THEN SKIP TO TERMINATE (has to be an array)
function terminate_if_only_others(source_id,others_answer,source_answer,pages)
    
    local c = false
    
    if term_if_only_others == false or others_answer == nil then return end
    
    -- THIS IS WHEN ITS A SINGLE ANSWER THEREFORE THE SOURCE ANSWER IS THE SAME AS OTHER ANSWER
    if source_answer == others_answer then c = true end

    if next(source_answer) == nil and others_answer ~= nil then
        c = true
    end
    
    if c then jumptopage(pages["terminate"]) else return end
end

--STANDARDIZE THE TEXT BY STRIPPING OFF SPACES AND TURNING INTO LOWER
function strip(str)
    return string.gsub(string.lower(str), "%s+", "")
end

--RETURN ARRAY OF SOURCE ANSWERS
--RETURN ARRAY OF SOURCE ANSWERS
function source(source_id, source_answer, source_answer_label)
    source_type = type(getvalue(source_id))
    --INITIALIZE THE SOURCE ANSWERS REGARDLESS IF PIPING TO ROW OR COLUMN
    if source_type == "table" then 
        source_answer = getvalue(source_id)
        source_answer_label = getvaluelabel(source_id)
    else 
        table.insert(source_answer,getvalue(source_id))
        table.insert(source_answer_label,getvaluelabel(source_id)) 
    end
	
	for k,v in pairs(source_answer) do
		if string.find(k,"other") then
			for m,n in pairs(source_answer_label)do
				if v == tostring(m) then
					source_answer_label[m] = nil
				end
			end
		end
	end

    for key,value in pairs(source_answer_label) do
        source_answer_label[key] = strip(value)
        if string.find(source_answer_label[key],"others") then
			source_answer_label[key] = nil
            others_answered = true
        end
    end

    return source_answer,source_answer_label
end

-- INITIALIZE THE PAGES STRING INTO AN ARRAY
function page_maker()
    local pages = {}

    for line in PAGES_ID:gmatch("(.-)\n") do
        page_title = nil
        page_id = nil
        for token in string.gmatch(line, "[^%s]+")do
            if page_title == nil then
                page_title = token
            elseif page_id == nil then
                page_id = tonumber(token)
            end
        end
        if page_title == "current" then pages[page_title] = currentpagesku()
        -- elseif page_title == "next" then pages[page_title] = 
        else pages[page_title] = page_id

        end
    end

    return pages
end

function question_type_func(pageid)
    local question_types = {}
    for _,types in pairs(MAIN_QUESTION_TYPES) do
        question_types[types] = allquestionsoftype(types,pageid)
    end
    return question_types
end

function round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
end

function between(num, a, b)
	if num >= a and num <= b then
		return true
	else
		return false
	end
end 

function multi_compare(c,...)
    local rst = false
    local ans = arg[1]
   
    if c == true then
        if ans >= arg[2] and ans <= arg[3] then
            -- print('ans:'..ans..' arg[2]:'..arg[2]..' arg[3]:'..arg[3])
            rst = true
        end
    else
        for i=2,(#arg+2) do
            if ans == arg[i] then
                -- print('ans:'..ans..' arg[2]:'..arg[2])
                rst = true
                break
            end
        end
    end

    -- if rst then print ('true') else print('false')end
    return rst
end

function cmp_multitype(op1, op2)
    local type1, type2 = type(op1), type(op2)
    if type1 ~= type2 then --cmp by type
        return type1 < type2
    elseif type1 == "number" or type1 == "string" then --type2 is equal to type1
        return op1 < op2 --comp by default
    elseif type1 == "boolean" then
        return op1 == true
    else
        return tostring(op1) < tostring(op2) --cmp by address
    end
end

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex, cmp_multitype )
    return orderedIndex
end

function orderedNext(t, state)
    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1,#t.__orderedIndex do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i+1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    return orderedNext, t, nil
end

function recurs_merge(...)
	local arr = {}
  	for i = 1, #arg do
    	arr = array_merge(arr,arg[i])
    end
  	return arr
end

main()