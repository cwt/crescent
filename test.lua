local message = ... or "lel"
for i = 1, #message, 1 do
  print(message:sub(1, i))
end
return "my awesome return value"