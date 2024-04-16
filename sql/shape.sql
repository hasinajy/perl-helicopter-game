CREATE DATABASE helicopter_game;

Use helicopter_game;

CREATE TABLE shape (
    shape_id INT PRIMARY KEY,
    coord_string VARCHAR(256) NOT NULL,
    isPlatform INT DEFAULT 0
);

-- Shape
INSERT INTO shape(coord_string) VALUES
    ("[]-[]-[]-[]");