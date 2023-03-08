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
assets = {
    quit = ui.Asset.File("images/quit.png"),
    ferris_wheel = ui.Asset.File("models/ThemePark.glb"),
}
app.assetManager:add(assets)

local bounds = ui.Bounds(0, 0, 0, 1, 1, 1)
local asset = assets.ferris_wheel

local ferris_view = ui.ModelView(bounds, asset)
app.mainView = ferris_view

    


-- Connect to the designated remote Place server
app:connect()
-- hand over runtime to the app! App will now run forever,
-- or until the app is shut down (ctrl-C or exit button pressed).
app:run()
