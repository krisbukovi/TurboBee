local M = {}

function M.getBibcode()

    local destination = ngx.var.request_uri

    if destination == nil then 

        return nil

    else

	local destination = destination:sub(6) -- Ignore '/abs/'

        local size = destination:len()  

        for i = 1, destination:len(), 1
	    do
                if destination:sub(i,i) == '/' then
	            size = i-1
		    break 
		end
            end

        return destination:sub(1, size) -- split at first '/', return full string if none are found  

    end
end 

function M.run()

    success, err = pg:connect()

    if success then

	local destination = ngx.var.request_uri:sub(6)

        local bibcode = M.getBibcode()

	if bibcode == nil or bibcode:len() ~= 19 then

            ngx.status=404
	    ngx.say("Bibcode should be 19 characters.")
	    ngx.exit(404)

        else 
	
	    --local target = ngx.var.scheme .. "://" .. ngx.var.host .. "/#abs/" .. bibcode .. "/abstract"
            local target = "https://dev.adsabs.harvard.edu" .. "/#abs/" .. bibcode .. "/abstract"
	    
	    local result = pg:query("SELECT content FROM pages WHERE target = " .. pg:escape_literal(target))

	    if result and result[1] and result[1]['content'] then
                
	        ngx.header.content_type = result[1]['content_type']

		ngx.say(result[1]['content'])

            else
                --ngx.status = 404
                --ngx.say("Record not found.")
                --return ngx.exit(404)

                local parameters = ngx.var.QUERY_STRING
                if parameters then
                    ngx.redirect("/#abs/" .. destination .. "?" .. parameters)
                else
                    ngx.redirect("/#abs/" .. destination)
                end
            end
	end
    else
	ngx.status=503
        ngx.say("Could not connect to db: " .. err)
        return ngx.exit(503)
    end

end

return M
