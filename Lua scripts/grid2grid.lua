s = 118
t = 160

sa = getvalue(s)
st = array_flip(gettablequestiontitles(s))
tt = array_flip(gettablequestiontitles(t))



for k,v in pairs(tt)do
	satitle = sa[st[k]]
  	if next(satitle) then
		for a,b in pairs(satitle)do
			val = tonumber(b)
			--you can change the value here according to your need
			if val > 5 then
			  hidequestion(v,true)
			end
		end
	else
		hidequestion(v,true)
	end
end