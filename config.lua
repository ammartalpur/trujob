Config = {}


Config.Debug = true
Config.CommandName = "trucker" 

Config.TruckSpawn = vector4(495.04, -634.82, 23.96, 261.21)
Config.Garage = {
    coords = vector4(502.61 , -610.04 , 23.75 , 165.01),
    radius = 5.0,
    ped = 's_m_m_trucker_01'
}


Config.Peds = {
    Dealer = {
        model = `a_m_m_business_01`,
        coords = vector4(500.1, -651.8, 23.91, 266.72), 
        label = "Truck Dealership",
        icon = "fas fa-truck-moving"
    },
    Logistics = {
        model = `s_m_m_postal_01`,
        coords = vector4(501.4, -630.47, 23.75, 262.22),
        label = "Logistics Manager",
        icon = "fas fa-clipboard-list"
    }
}


Config.Trucks = {
    { model = `phantom`, label = "Phantom Classic", price = 55000, image = "phantom.png" },
    { model = `hauler`,  label = "Vapid Hauler",   price = 75000, image = "hauler.png" },
    { model = `packer`,  label = "MTL Packer",     price = 45000, image = "packer.png" }
}


Config.BasePayPerMeter = 0.5 



Config.Routes = {
    {
        id = 1,
        label = "Grocery Store Restock",
        pickup = vector4(503.94 , -582.14 , 23.99 , 191.51),
        dropoff = vector4(188.77 , -1469.09 , 27.44 , 138.07),
        trailerModel = `trailers2`, 
        payout = 1500,
        cargo = "Food & Beverages"
    },

}
