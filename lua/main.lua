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

-- Gets the bounding box for the model
local bb = assets.ferris_wheelcart:model():getAABB()
local wheelcart_view = ui.ModelView(
    ui.Bounds(0, 0, 0, bb.size.x, bb.size.y, bb.size.z),
    assets.ferris_wheelcart
)
-- Makes it touchable
wheelcart_view.collider = bb

-- Holds the wheelcart_view in place; wrapper for cart rotation
local wheelcart = ui.View(
    ui.Bounds(11, 0, -1, 1, 1, 1)
)

-- This is the the Parent/Child objects
wheelstand_view:addSubview(wheel_view)
wheelcart:addSubview(wheelcart_view)
wheel_view:addSubview(wheelcart)


-- When user touches the cart
wheelcart_view.onTouchDown = function(self, pointer)
    local avatar = pointer.hand:getParent()
    -- TODO: set avatar parent to cart
    print(avatar)
    app:updateComponents(avatar, {
        relationships = {
            parent = wheelcart_view.entity.id
        }
    })
end


app.mainView = wheelstand_view

-- This is the animation to the assets
local speed = 0.01
app:scheduleAction(0.05, true, function ()
    -- function bounds:rotate(angle, x, y, z) d
    wheel_view:setBounds(wheel_view.bounds:rotate(speed, 0, 0, 1))
    wheelcart_view:setBounds(wheelcart_view.bounds:rotate(speed, 0, 0, -1))
end)




-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()

