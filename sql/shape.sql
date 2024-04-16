CREATE DATABASE helicopter_game;

Use helicopter_game;

CREATE TABLE shape (
    shape_id INT PRIMARY KEY auto_increment,
    coord_string VARCHAR(256) NOT NULL,
    isPlatform INT DEFAULT 0
);

-- Shape
INSERT INTO shape(coord_string, isPlatform) VALUES
    ("[0;300]-[100;300]-[100;350]-[0;350]", -1),
    ("[700;100]-[800;100]-[800;150]-[700;150]", 1),
    ("[200;0]-[300;0]-[300;300]-[200;300]", 0),
    ("[500;450]-[600;450]-[600;150]-[500;150]", 0);