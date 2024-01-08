-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2024. Jan 08. 13:12
-- Kiszolgáló verziója: 10.4.28-MariaDB
-- PHP verzió: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `basic-rp`
--

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `houses`
--

CREATE TABLE `houses` (
  `id` int(11) NOT NULL,
  `OwnerSQL` int(11) NOT NULL DEFAULT 0,
  `Name` varchar(40) NOT NULL DEFAULT 'None',
  `ExtX` float NOT NULL,
  `ExtY` float NOT NULL,
  `ExtZ` float NOT NULL,
  `ExtA` float NOT NULL,
  `IntX` float NOT NULL,
  `IntY` float NOT NULL,
  `IntZ` float NOT NULL,
  `IntA` float NOT NULL,
  `IntID` int(11) NOT NULL,
  `Price` int(11) NOT NULL DEFAULT 10000,
  `Locked` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `houses`
--

INSERT INTO `houses` (`id`, `OwnerSQL`, `Name`, `ExtX`, `ExtY`, `ExtZ`, `ExtA`, `IntX`, `IntY`, `IntZ`, `IntA`, `IntID`, `Price`, `Locked`) VALUES
(1, 4, 'testhouse', -223.001, 1099.18, 19.594, 79.668, -228.879, 1107.01, 19.742, 34.668, 0, 125, 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ownedcars`
--

CREATE TABLE `ownedcars` (
  `id` int(11) NOT NULL,
  `OwnerID` int(11) NOT NULL DEFAULT 0,
  `LockState` int(11) NOT NULL DEFAULT 0,
  `ModelID` int(11) NOT NULL DEFAULT 0,
  `Color1` int(11) NOT NULL DEFAULT 0,
  `Color2` int(11) NOT NULL DEFAULT 0,
  `Plate` varchar(10) NOT NULL DEFAULT 'None',
  `PlateX` float NOT NULL DEFAULT 0,
  `PlateY` float NOT NULL DEFAULT 0,
  `PlateZ` float NOT NULL DEFAULT 0,
  `PlateA` float NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `players`
--

CREATE TABLE `players` (
  `id` int(11) NOT NULL,
  `Name` varchar(30) NOT NULL,
  `Password` varchar(255) NOT NULL,
  `RegIP` varchar(20) NOT NULL,
  `AdminLevel` int(11) NOT NULL DEFAULT 0,
  `Money` int(11) NOT NULL DEFAULT 0,
  `Level` int(11) NOT NULL DEFAULT 1,
  `Respect` int(11) NOT NULL DEFAULT 0,
  `LastX` float NOT NULL DEFAULT -88.9697,
  `LastY` float NOT NULL DEFAULT 1225.39,
  `LastZ` float NOT NULL DEFAULT 19.7422,
  `LastRot` float NOT NULL DEFAULT 178.881,
  `Interior` int(11) NOT NULL DEFAULT 0,
  `VW` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- A tábla adatainak kiíratása `players`
--

INSERT INTO `players` (`id`, `Name`, `Password`, `RegIP`, `AdminLevel`, `Money`, `Level`, `Respect`, `LastX`, `LastY`, `LastZ`, `LastRot`, `Interior`, `VW`) VALUES
(4, 'testuser', '5f5ea3800d9a62bc5a008759dbbece9cad5db58f', '127.0.0.1', 5, 29875, 1, 0, -239.268, 1125.56, 19.742, 175.093, 0, 0);

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `houses`
--
ALTER TABLE `houses`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `ownedcars`
--
ALTER TABLE `ownedcars`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `houses`
--
ALTER TABLE `houses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `ownedcars`
--
ALTER TABLE `ownedcars`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `players`
--
ALTER TABLE `players`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
