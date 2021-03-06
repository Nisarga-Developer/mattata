--[[
    Copyright 2020 Matthew Hesketh <matthew@matthewhesketh.com>
    This code is licensed under the MIT. See LICENSE for details.
]]

local drawtext = {}
local mattata = require('mattata')
local http = require('socket.http')
local url = require('socket.url')

function drawtext:init(configuration)
    drawtext.commands = mattata.commands(self.info.username):command('drawtext').table
    drawtext.help = '/drawtext [text] - Converts the given/replied-to text to an image.'
    drawtext.limit = configuration.limits.drawtext
    drawtext.url = 'http://api.img4me.com/?font=arial&size=24&bcolor=&type=png&text='
end

function drawtext.on_message(_, message, _, language)
    local input = message.reply and message.reply.text or mattata.input(message.text)
    if not input then
        return mattata.send_reply(message, drawtext.help)
    elseif input:len() > drawtext.limit then
        input = input:sub(1, (drawtext.limit - 3)) .. '...'
    end
    local str, res = http.request(drawtext.url .. url.escape(input))
    if not str or res ~= 200 then
        return mattata.send_reply(message, language.errors.connection)
    end
    mattata.send_chat_action(message.chat.id, 'upload_photo')
    return mattata.send_photo(message.chat.id, str)
end

return drawtext