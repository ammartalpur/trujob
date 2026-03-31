import React, { useState } from "react";
import "./App.css";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { fetchNui } from "../utils/fetchNui";


interface Truck {
  model: string;
  label: string;
  price: number;
  plate?: string;
}

const App: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [tab, setTab] = useState<"shop" | "garage">("shop");
  const [catalog, setCatalog] = useState<Truck[]>([]);
  const [ownedTrucks, setOwnedTrucks] = useState<Truck[]>([]);


  useNuiEvent<boolean>("setVisible", (isVisible) => {
    console.log("React received setVisible:", isVisible);
    setVisible(isVisible);
  });


  useNuiEvent<Truck[]>("OPEN_DEALER", (data) => {
    console.log("React received OPEN_DEALER payload:", data);
    if (data) {
      setCatalog(data);
    }
  });

 
  useNuiEvent<Truck[]>("UPDATE_OWNED", (data) => {
    console.log("React received UPDATE_OWNED payload:", data);
    if (data) {
      setOwnedTrucks(data);
    }
  });

  const handleBuy = (truck: Truck) => {
    console.log("React: Sending buyTruck for", truck.model);

    fetchNui("buyTruck", truck)
      .then((resp) => {
        console.log("React: Lua responded with:", resp);
      })
      .catch((err) => {
        console.error("React: fetchNui failed!", err);
      });
  };

  const handleSpawn = (plate: string) => {
    fetchNui("spawnOwnedTruck", { plate });
    handleClose();
  };

  const handleClose = () => {
    setVisible(false);
    fetchNui("hideFrame");
  };

  if (!visible) return null;

  return (
    <div className="dealer-wrapper">
      <div className="dealer-container">
        <header>
          <h1>TRUCK CENTER</h1>
          <nav>
            <button
              className={tab === "shop" ? "active" : ""}
              onClick={() => setTab("shop")}
            >
              STORE
            </button>
            <button
              className={tab === "garage" ? "active" : ""}
              onClick={() => setTab("garage")}
            >
              MY GARAGE
            </button>
          </nav>
        </header>

        <main className="truck-grid">
          {tab === "shop" ? (
            catalog.length > 0 ? (
              catalog.map((truck) => (
                <div key={truck.model} className="truck-card">
                  <div className="truck-img-placeholder">
                    {truck.label.charAt(0)}
                  </div>
                  <h3>{truck.label}</h3>
                  <p className="price">${truck.price.toLocaleString()}</p>
                  <button
                    className="action-btn buy"
                    onClick={() => handleBuy(truck)}
                  >
                    PURCHASE
                  </button>
                </div>
              ))
            ) : (
              <p className="loading-text">LOADING CATALOG...</p>
            )
          ) : ownedTrucks.length > 0 ? (
            ownedTrucks.map((truck) => (
              <div key={truck.plate} className="truck-card">
                <div className="truck-img-placeholder owned">OWNED</div>
                <h3>{truck.label}</h3>
                <p className="plate">PLATE: {truck.plate}</p>
                <button
                  className="action-btn spawn"
                  onClick={() => handleSpawn(truck.plate!)}
                >
                  SPAWN
                </button>
              </div>
            ))
          ) : (
            <p className="loading-text">GARAGE EMPTY</p>
          )}
        </main>

        <button className="close-btn" onClick={handleClose}>
          EXIT
        </button>
      </div>
    </div>
  );
};

export default App;
