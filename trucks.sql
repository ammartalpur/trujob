CREATE TABLE IF NOT EXISTS `player_trucks` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `plate` VARCHAR(15) NOT NULL UNIQUE, -- Added UNIQUE to prevent duplicate plates
    `label` VARCHAR(50) DEFAULT 'Truck',
    `in_garage` TINYINT(1) DEFAULT 1,    -- 1 = Stored, 0 = Out in the world
    `garage_name` VARCHAR(50) DEFAULT 'TruckDepot',
    `fuel` INT DEFAULT 100,
    `engine_health` INT DEFAULT 1000,
    `body_health` INT DEFAULT 1000,
    INDEX (`citizenid`),
    INDEX (`plate`)                     -- Added index for faster spawning lookups
);