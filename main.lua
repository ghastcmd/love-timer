local buttons = {}
local timers = {}
local edit_buttons = {}
local close_edit = {}
local input_texts = {}

local clicked_state = {
    clicked = false,
    edit_clicked = false,
    current_timer_name = "",
    pos = 0,
    edit_pos = 0,
}

local edit_page = {
    inputbox1 = "",
    inputbox2 = "",
    inputbox3 = "",
    current_box_pos = 0,
}
clicked_state.__index = self
setmetatable(clicked_state, self)

local canvas_index = 0

function write_canvas(text)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, canvas_index * 15 + 1, 300, 15)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, 0, canvas_index * 15, 100, "left")
    
    canvas_index = canvas_index + 1
end

function write_canvas_reset_index()
    canvas_index = 0
end

function create_button(x, y, width, height, color, hoverColor, text, align, textcolor)
    if align == nil then
        align = "center"
    end

    if textcolor == nil then
        textcolor = {1, 1, 1}
    end

    return {
        x = x,
        y = y,
        width = width,
        height = height,
        color = color,
        hoverColor = hoverColor,
        isHovered = false,
        text = text,
        align = align,
        textcolor = textcolor,
    }
end

function inside_bounding_box(x, y, but)
    return x > but.x and x < but.x + but.width and y > but.y and y < but.y + but.height
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
    love.graphics.setColor(unpack(buttonctx.textcolor))
    love.graphics.printf(buttonctx.text, new_x, new_y + 18 * scale, buttonctx.width * scale, buttonctx.align)
end

function love.mousemoved(x, y)
    for k, but in pairs(buttons) do
        but.isHovered = inside_bounding_box(x, y, but)
    end

    for k, but in pairs(edit_buttons) do
        but.isHovered = inside_bounding_box(x, y, but)
    end

    close_edit.isHovered = inside_bounding_box(x, y, close_edit)
end

function love.textinput(t)
    local pos = edit_page.current_box_pos
    input_texts[pos].text = input_texts[pos].text .. t
end


-- local textField = {
--     x = 100,
--     y = 200,
--     width = 200,
--     height = 30,
--     text = "",
--     isActive = false
-- }

-- function love.textinput(t)
--     if textField.isActive then
--         textField.text = textField.text .. t
--     end
-- end

function draw_edit()
    local x = 50
    local y = 50
    local width = 350
    local height = 350

    -- background
    love.graphics.setColor(1.0, 0.3, 0.3)
    love.graphics.rectangle("fill", 50, 50, 350, 350)

    -- title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(clicked_state.current_timer_name, x, y + 20, width, "center")

    draw_button(close_edit)

    -- close button
    -- love.graphics.setColor(1.0, 0.4, 0.4)
    -- love.graphics.rectangle("fill", 50 + 300, 50, 50, 50)

    -- x close name
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.printf("x", 50 + width - 30, 50 + 18, 10, "center")

    -- love.graphics.setColor(1, 1, 1)

    local initial_x = 50
    local initial_y = 70
    local text_area_width = 70
    local gap = 25

    for k, textboxes in pairs(input_texts) do
        draw_button(textboxes)
    end
end

function clicked_state:update_click(pos)
    self.clicked = true
    self.pos = pos

    timers[pos].is_running = not timers[pos].is_running
    
    if timers[pos].is_ended then
        timers[pos]:reset_timer()
    end
end

function clicked_state:update_edit_click(pos)
    self.edit_clicked = not self.edit_clicked
    -- self.pos = pos
    self.edit_pos = pos

    clicked_state.current_timer_name = "timer " .. pos
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for k, button in pairs(buttons) do
            if inside_bounding_box(x, y, button) and not clicked_state.edit_clicked then
                clicked_state:update_click(k)
            end
        end

        for k, edit_button in pairs(edit_buttons) do
            if inside_bounding_box(x, y, edit_button) and not clicked_state.edit_clicked then
                clicked_state:update_edit_click(k)
            end
        end

        if clicked_state.edit_clicked then
            if inside_bounding_box(x, y, close_edit) then
                clicked_state:update_edit_click(0)
            end
        end

        if clicked_state.edit_clicked then
            for k, input_text in pairs(input_texts) do
                if inside_bounding_box(x, y, input_text) then
                    edit_page.current_box_pos = k
                end
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

    edit_buttons[1] = create_button(100 + 200 + 10, 100, 40, 50, {1.0, 0.3, 0.3}, {1.0, 0.4, 0.4}, ">")
    edit_buttons[2] = create_button(100 + 200 + 10, 200, 40, 50, {1.0, 0.3, 0.3}, {1.0, 0.4, 0.4}, ">")
    edit_buttons[3] = create_button(100 + 200 + 10, 300, 40, 50, {1.0, 0.3, 0.3}, {1.0, 0.4, 0.4}, ">")

    close_edit = create_button(350, 50, 50, 50, {1.0, 0.4, 0.4}, {1.0, 0.5, 0.5}, "x")

    
    local x = 50
    local y = 50
    local initial_x = 50
    local initial_y = 70
    local text_area_width = 70
    local gap = 25

    -- love.graphics.rectangle("fill", x + initial_x, y + initial_y, text_area_width, 50)

    -- love.graphics.rectangle("fill", x + initial_x + text_area_width + gap, y + initial_y, text_area_width, 50)

    -- love.graphics.rectangle("fill", x + initial_x + text_area_width * 2 + gap * 2, y + initial_y, text_area_width, 50)

    input_texts[1] = create_button(x + initial_x, y + initial_y, text_area_width, 50, {1, 1, 1}, {1, 1, 1}, "", "center", {0, 0, 0})
    input_texts[2] = create_button(x + initial_x + text_area_width + gap, y + initial_y, text_area_width, 50, {1, 1, 1}, {1, 1, 1}, "", "center", {0, 0, 0})
    input_texts[3] = create_button(x + initial_x + text_area_width * 2 + gap * 2, y + initial_y, text_area_width, 50, {1, 1, 1}, {1, 1, 1}, "", "center", {0, 0, 0})

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

    for k, but in pairs(edit_buttons) do
        draw_button(but)
    end
    
    -- love.graphics.printf(timers[1].current_time, 0, 10, 100, "left")
    write_canvas(timers[1].current_time)
    if timers[1]:check_ended() then
        write_canvas("Started")
        -- love.graphics.printf("Started", 0, 0, 100, "left")
    end

    if clicked_state.clicked then
        write_canvas("clicked " .. tostring(clicked_state.pos))
        -- love.graphics.printf(, 0, 0, 100, "left")
    end

    if clicked_state.edit_clicked then
        write_canvas("cliked edit")
        draw_edit()
    end

    write_canvas_reset_index()
end