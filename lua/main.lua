-- a Client is used to connect this app to a Place. arg[2] is the URL of the place to
-- connect to, which Assist sets up for you.
local client = Client(
    arg[2], 
    "AmusementPark"
)

-- App manages the Client connection for you, and manages the lifetime of the
-- your app.
local app = App(client)

-- Assets are files (images, glb models, videos, sounds, etc...) that you want to use
-- in your app. They need to be published so that user's headsets can download them
-- before you can use them. We make `assets` global so you can use it throughout your app.

--These are imported models that become assets

assets = {
    quit = ui.Asset.File("images/quit.png"),
    ferris_wheelstand = ui.Asset.File("models/FerryWheelStand.glb"),
    ferris_wheel = ui.Asset.File("models/FerryWheel.glb"),
    ferris_wheelcart = ui.Asset.File("models/FerryWheelCart.glb")
}
app.assetManager:add(assets)

-- These are the assets that are visible in Allo (axis: x, y, z, scale: 1, 1, 1)

local wheelstand_view = ui.ModelView(
    ui.Bounds(0, 0, 0, 1, 1, 1),
    assets.ferris_wheelstand
)

local wheel_view = ui.ModelView(
    ui.Bounds(0, 0, 0, 1, 1, 1),
    assets.ferris_wheel
)

local manycarts = ui.View(
    ui.Bounds(0, 0, 0, 1, 1, 1)
)

-- Gets the bounding box for the model
local bb = assets.ferris_wheelcart:model():getAABB()

local carts = {}

for i = 1, 6 do
    local wheelcart_view = ui.ModelView(
        ui.Bounds(0, 0, 0, bb.size.x, bb.size.y, bb.size.z),
        assets.ferris_wheelcart
    )
    -- Makes it touchable
    wheelcart_view.collider = bb

    -- Holds the wheelcart_view in place; wrapper for cart rotation (Empty Object parented with the wheelcart)
    local wheelcart = ui.View(
        ui.Bounds(11 * math.cos(math.pi/3 * i), 11 * math.sin(math.pi/3 * i), -1, 1, 1, 1)
    )

    -- A dummy view to offset the avatar to the ground of the cart
    local avatarOffsetView = ui.View()
    avatarOffsetView.bounds:move(0, -3, 0)
    wheelcart_view:addSubview(avatarOffsetView)
   

    wheelcart_view.onTouchDown = function(self, pointer)
        local avatar = pointer.hand:getParent()

        if avatar.components.relationships == nil or avatar.components.relationships.parent == nil then 
            app:updateComponents(avatar, {
                relationships = {
                    parent = avatarOffsetView.entity.id
                }
            })
        else 
            app:updateComponents(avatar, {
                relationships = {}
            })
        end
    end

    -- Parenting empty objects with the wheelcart along with a smoother animation with the help of (PropertyANimation)
    wheelcart:addSubview(wheelcart_view)

    wheelcart_view:doWhenAwake(function() 
        wheelcart_view:addPropertyAnimation(ui.PropertyAnimation{
            path = "transform.matrix.rotation.z",
            start_at = app:serverTime() + 1.0, 
            from = 0,
            to =  math.pi * -2,
            duration = 30.0,
            repeats = true,
            autoreverses = false,
            easing = "linear",
        })
    end)

    manycarts:addSubview(wheelcart)
    table.insert(carts, wheelcart_view)
end 

-- Empty object for the center of the ferry wheel to help it rotate properly
local wheelcenter = ui.View(
    ui.Bounds(0, 15, 0, 1 ,1 ,1)
)

-- This is the the Parent/Child objects
wheelstand_view:addSubview(wheelcenter)
wheelcenter:addSubview(wheel_view)
wheel_view:addSubview(manycarts)




-- PropertyAnimation

wheel_view:doWhenAwake(function() 
    wheel_view:addPropertyAnimation(ui.PropertyAnimation{
        path= "transform.matrix.rotation.z",
        start_at = app:serverTime() + 1.0, 
        from= -0,
        to=   math.pi * 2,
        duration = 30.0,
        repeats= true,
        autoreverses= false,
        easing= "linear",
    })    
end)

 
app.mainView = wheelstand_view

-- This is the animation to the assets
-- local speed = 0.01
-- app:scheduleAction(0.05, true, function ()
 ----   for i, cart in ipairs(carts) do 
     --  cart:setBounds(cart.bounds:rotate(speed, 0, 0, -1))
 --   end
    -- function bounds:rotate(angle, x, y, z) d
--    wheel_view:setBounds(wheel_view.bounds:rotate(speed, 0, 0, 1))
    
-- end)



-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()

