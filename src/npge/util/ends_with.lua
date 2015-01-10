return function(str, suffix)
   return suffix == '' or str:sub(-suffix:len()) == suffix
end
