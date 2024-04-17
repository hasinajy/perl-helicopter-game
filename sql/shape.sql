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
    ("[200;75]-[250;0]-[300;75]-[250;150]", 0),
    ("[500;450]-[600;450]-[600;150]-[500;150]", 0);

-- Exam
INSERT INTO shape(coord_string, isPlatform) VALUES
    ("[200;100]-[250;100]-[250;800]-[200;800]", 0),
    ("[350;70]-[400;70]-[400;800]-[350;800]", 0),
    ("[500;70]-[550;70]-[550;800]-[500;800]", 0);