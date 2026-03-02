local buttons = {}
local timers = {}

function create_button(x, y, width, height, color, hoverColor, text)
    return {
        x = x,
        y = y,
        width = width,
        height = height,
        color = color,
        hoverColor = hoverColor,
        isHovered = false,
        text = text
    }
end

function create_timer(end_time, limit_time)
    local timer = {
        end_time = end_time,
        limit_time = limit_time,
        current_time = 0.0,
        is_running = false,
        is_ended = false
    }
    timer.__index = self

    setmetatable(timer, self)

    function timer:update_timer()
        if self.is_running == true then
            if not self:check_ended() then
                self.current_time = self.current_time + love.timer.getDelta()
            else
                self.is_ended = true
            end
        end
    end

    function timer:check_ended()
        return self.current_time >= self.end_time
    end

    function timer:reset_timer()
        if self.is_ended then
            self.current_time = 0.0
            self.is_running = false
            self.is_ended = false
        end
    end

    return timer
end

function draw_button(buttonctx)
    -- Draw button with animation
    local scale = buttonctx.isHovered and 1.05 or 1
    love.graphics.setColor(buttonctx.isHovered and buttonctx.hoverColor or buttonctx.color)
    local new_x = -((buttonctx.width * scale) - buttonctx.width) / 2 + buttonctx.x
    local new_y = -((buttonctx.height * scale) - buttonctx.height) / 2 + buttonctx.y
    love.graphics.rectangle("fill", new_x, new_y, buttonctx.width * scale, buttonctx.height * scale)
    
    -- Draw text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(buttonctx.text, new_x, new_y + 18 * scale, buttonctx.width * scale, "center")
end

function love.mousemoved(x, y)
    for k, but in pairs(buttons) do
        but.isHovered = x > but.x and x < but.x + but.width and y > but.y and y < but.y + but.height
    end
end

local textField = {
    x = 100,
    y = 200,
    width = 200,
    height = 30,
    text = "",
    isActive = false
}

function love.textinput(t)
    if textField.isActive then
        textField.text = textField.text .. t
    end
end

local canvas_index = 0

function write_canvas(text)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, canvas_index * 15 + 1, 100, 15)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, 0, canvas_index * 15, 100, "left")
    
    canvas_index = canvas_index + 1
end

function write_canvas_reset_index()
    canvas_index = 0
end

local clicked_state = {
    clicked = false,
    pos = 0
}

clicked_state.__index = self
setmetatable(clicked_state, self)

function clicked_state:update_click(pos)
    self.clicked = true
    self.pos = pos

    timers[pos].is_running = not timers[pos].is_running
    
    if timers[pos].is_ended then
        timers[pos]:reset_timer()
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for k, button in pairs(buttons) do
            if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
                clicked_state:update_click(k)
            end
        end
    end
end

function love.load()
    timers[1] = create_timer(2.0, 3.0)
    timers[2] = create_timer(2.0, 3.0)
    timers[3] = create_timer(2.0, 3.0)
    
    buttons[1] = create_button(100, 100, 200, 50, {1.0, 0.3, 0.3}, {1.0, 0.4, 0.4}, "Text")
    buttons[2] = create_button(100, 200, 200, 50, {1.0, 0.3, 0.3}, {1.0, 0.4, 0.4}, "Text")
    buttons[3] = create_button(100, 300, 200, 50, {1.0, 0.3, 0.3}, {1.0, 0.4, 0.4}, "Text")
end

function love.update(dt)
    for k, timer in pairs(timers) do
        timer:update_timer()
    end
end

local current_time = 0.0

function love.draw()
    for k, button in pairs(buttons) do
        button.text = tostring(timers[k].current_time)
        draw_button(button)
    end
    
    -- love.graphics.printf(timers[1].current_time, 0, 10, 100, "left")
    write_canvas(timers[1].current_time)
    if timers[1]:check_ended() then
        write_canvas("Started")
        -- love.graphics.printf("Started", 0, 0, 100, "left")
    end

    if clicked_state.clicked then
        write_canvas("clicked" .. tostring(clicked_state.pos))
        -- love.graphics.printf(, 0, 0, 100, "left")
    end

    write_canvas_reset_index()
end