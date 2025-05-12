BLLCommandPanel = ISPanel:derive("BLLCommandPanel")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local FONT_HGT_MEDIUM = getTextManager():getFontHeight(UIFont.Medium)
local UI_BORDER_SPACING = 10
local BUTTON_HGT = FONT_HGT_SMALL + 6

function BLLCommandPanel:initialise()
    ISPanel.initialise(self)

    local buttons = {
        FOLLOW = {
            txt = "F",
            tooltip = "Follow behind"
        },
        PERIMITER = {
            txt = "P",
            tooltip = "Form defensive perimiter"
        }
    }
    local leftX = UI_BORDER_SPACING

    self.buttons = {}
    for internal, buttonData in pairs(buttons) do
        self.buttons[internal] = ISButton:new(leftX, UI_BORDER_SPACING, BUTTON_HGT, BUTTON_HGT, buttonData.txt, self, BLLCommandPanel.onClick)
        self.buttons[internal].internal = internal
        self.buttons[internal].anchorTop = false
        self.buttons[internal].anchorBottom = true
        self.buttons[internal]:initialise()
        self.buttons[internal]:instantiate()
        self.buttons[internal].tooltip = buttonData.tooltip
        self:addChild(self.buttons[internal])

        leftX = leftX + BUTTON_HGT + 5
    end


    self.cancel = ISButton:new(self:getWidth() - 40, self:getHeight() - BUTTON_HGT, 40, BUTTON_HGT, "C", self, BLLCommandPanel.onClick)
    self.cancel.internal = "CLOSE"
    self.cancel.anchorTop = false
    self.cancel.anchorBottom = true
    self.cancel:initialise()
    self.cancel:instantiate()
    if BanditCompatibility.GetGameVersion() >= 42 then
        self.cancel:enableCancelColor()
    end
    self:addChild(self.cancel)

end


function BLLCommandPanel:onClick(button)
    if button.internal == "CLOSE" then
        self:removeFromUIManager()
        self:close()
    end
end

function BLLCommandPanel:onRightClick(button)
end

function BLLCommandPanel:update()
    ISPanel.update(self)
end

function BLLCommandPanel:prerender()
    ISPanel.prerender(self)
end

function BLLCommandPanel:new(x, y, width, height)
    local o = {}
    o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
    o.backgroundColor = {r=0, g=0, b=0, a=0.8}
    o.width = width
    o.height = height
    o.moveWithMouse = true
    BLLCommandPanel.instance = o
    ISDebugMenu.RegisterClass(self)
    return o
end
