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

local bounds_for_wheelstand = ui.Bounds(0, 0, 0, 1, 1, 1)
local wheelstand_view = ui.ModelView(bounds_for_wheelstand, assets.ferris_wheelstand)

local bounds_for_wheel = ui.Bounds(0, 0, 0, 1, 1, 1)
local wheel_view = ui.ModelView(bounds_for_wheel, assets.ferris_wheel)

local bounds_for_wheelcart = ui.Bounds(11, 0, -1, 1, 1, 1)
local wheelcart = ui.View(bounds_for_wheelcart)


local bounds_for_wheelcart = ui.Bounds(0, 0, 0, 1, 1, 1)
local wheelcart_view = ui.ModelView(bounds_for_wheelstand, assets.ferris_wheelcart)


-- This is the the Parent/Child objects

wheelstand_view:addSubview(wheel_view)
wheelcart:addSubview(wheelcart_view)
wheel_view:addSubview(wheelcart)  


app.mainView = wheelstand_view

-- This is the animation to the assets
wheelcart_view:setBounds(bounds_for_wheelcart)
app:scheduleAction(0.05, true, function ()
    -- function bounds:rotate(angle, x, y, z) d
        wheel_view:setBounds(wheel_view.bounds:rotate(0.03, 0, 0, 1))

            -- function bounds:rotate(angle, x, y, z)
                 wheelcart_view:setBounds(wheelcart_view.bounds:rotate(0.03, 0, 0, -1))
                 
end)




-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()

