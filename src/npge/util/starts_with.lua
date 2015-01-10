return function(str, prefix)
   return str:sub(1, prefix:len()) == prefix
end
