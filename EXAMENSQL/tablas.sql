-- Primero creamos las tablas independientes (sin foreign keys)

-- Country table
CREATE TABLE pais (
    id_pais SMALLINT UNSIGNED PRIMARY KEY,
    nombre VARCHAR(50),
    ultima_actualizacion TIMESTAMP
);

-- City table (ahora que pais ya existe)
CREATE TABLE ciudad (
    id_ciudad SMALLINT UNSIGNED PRIMARY KEY,
    nombre VARCHAR(50),
    id_pais SMALLINT UNSIGNED,
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_pais) REFERENCES pais (id_pais)
);

-- Direction (address) table (ahora que ciudad ya existe)
CREATE TABLE direccion (
    id_direccion SMALLINT UNSIGNED PRIMARY KEY,
    direccion VARCHAR(50),
    direccion2 VARCHAR(50),
    distrito VARCHAR(20),
    id_ciudad SMALLINT UNSIGNED,
    codigo_postal VARCHAR(10),
    telefono VARCHAR(20),
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_ciudad) REFERENCES ciudad (id_ciudad)
);

-- Language table
CREATE TABLE idioma (
    id_idioma TINYINT UNSIGNED PRIMARY KEY,
    nombre CHAR(20),
    ultima_actualizacion TIMESTAMP
);

-- Category table
CREATE TABLE categoria (
    id_categoria TINYINT UNSIGNED PRIMARY KEY,
    nombre VARCHAR(25),
    ultima_actualizacion TIMESTAMP
);

-- Actor table
CREATE TABLE actor (
    id_actor SMALLINT UNSIGNED PRIMARY KEY,
    nombre VARCHAR(45),
    apellidos VARCHAR(45),
    ultima_actualizacion TIMESTAMP
);

-- Store and Employee tables (tienen referencias circulares, primero creamos sin FK)
CREATE TABLE almacen (
    id_almacen TINYINT UNSIGNED PRIMARY KEY,
    id_empleado_jefe TINYINT UNSIGNED,
    id_direccion SMALLINT UNSIGNED,
    ultima_actualizacion TIMESTAMP
);

CREATE TABLE empleado (
    id_empleado TINYINT UNSIGNED PRIMARY KEY,
    nombre VARCHAR(45),
    apellidos VARCHAR(45),
    id_direccion SMALLINT UNSIGNED,
    imagen BLOB,
    email VARCHAR(50),
    id_almacen TINYINT UNSIGNED,
    activo TINYINT(1),
    username VARCHAR(16),
    password VARCHAR(40),
    ultima_actualizacion TIMESTAMP
);

-- Film table (ahora que idioma ya existe)
CREATE TABLE pelicula (
    id_pelicula SMALLINT UNSIGNED PRIMARY KEY,
    titulo VARCHAR(255),
    descripcion TEXT,
    anyo_lanzamiento YEAR,
    id_idioma TINYINT UNSIGNED,
    id_idioma_original TINYINT UNSIGNED,
    duracion_alquiler TINYINT UNSIGNED,
    rental_rate DECIMAL(4,2),
    duracion SMALLINT UNSIGNED,
    replacement_cost DECIMAL(5,2),
    clasificacion ENUM('G','PG','PG-13','R','NC-17'),
    caracteristicas_especiales SET('Trailers','Commentaries','Deleted Scenes','Behind the Scenes'),
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_idioma) REFERENCES idioma (id_idioma),
    FOREIGN KEY (id_idioma_original) REFERENCES idioma (id_idioma)
);

-- Customer table
CREATE TABLE cliente (
    id_cliente SMALLINT UNSIGNED PRIMARY KEY,
    id_almacen TINYINT UNSIGNED,
    nombre VARCHAR(45),
    apellidos VARCHAR(45),
    email VARCHAR(50),
    id_direccion SMALLINT UNSIGNED,
    activo TINYINT(1),
    fecha_creacion DATETIME,
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_almacen) REFERENCES almacen (id_almacen),
    FOREIGN KEY (id_direccion) REFERENCES direccion (id_direccion)
);

-- Inventory table
CREATE TABLE inventario (
    id_inventario MEDIUMINT UNSIGNED PRIMARY KEY,
    id_pelicula SMALLINT UNSIGNED,
    id_almacen TINYINT UNSIGNED,
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula),
    FOREIGN KEY (id_almacen) REFERENCES almacen (id_almacen)
);

-- Film text table (for full-text search)
CREATE TABLE film_text (
    film_id SMALLINT,
    title VARCHAR(255),
    description TEXT,
    FOREIGN KEY (film_id) REFERENCES pelicula (id_pelicula)
);

-- Film category relationship table
CREATE TABLE pelicula_categoria (
    id_pelicula SMALLINT UNSIGNED,
    id_categoria TINYINT UNSIGNED,
    ultima_actualizacion TIMESTAMP,
    PRIMARY KEY (id_pelicula, id_categoria),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula),
    FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria)
);

-- Film actor relationship table
CREATE TABLE pelicula_actor (
    id_actor SMALLINT UNSIGNED,
    id_pelicula SMALLINT UNSIGNED,
    ultima_actualizacion TIMESTAMP,
    PRIMARY KEY (id_actor, id_pelicula),
    FOREIGN KEY (id_actor) REFERENCES actor (id_actor),
    FOREIGN KEY (id_pelicula) REFERENCES pelicula (id_pelicula)
);

-- Rental table
CREATE TABLE alquiler (
    id_alquiler INT PRIMARY KEY,
    fecha_alquiler DATETIME,
    id_inventario MEDIUMINT UNSIGNED,
    id_cliente SMALLINT UNSIGNED,
    fecha_devolucion DATETIME,
    id_empleado TINYINT UNSIGNED,
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_inventario) REFERENCES inventario (id_inventario),
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado)
);

-- Payment table
CREATE TABLE pago (
    id_pago SMALLINT UNSIGNED PRIMARY KEY,
    id_cliente SMALLINT UNSIGNED,
    id_empleado TINYINT UNSIGNED,
    id_alquiler INT,
    total DECIMAL(5,2),
    fecha_pago DATETIME,
    ultima_actualizacion TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
    FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
    FOREIGN KEY (id_alquiler) REFERENCES alquiler (id_alquiler)
);

-- Ahora añadimos las foreign keys para las tablas con referencias circulares
ALTER TABLE empleado
    ADD CONSTRAINT fk_empleado_almacen FOREIGN KEY (id_almacen) REFERENCES almacen (id_almacen),
    ADD CONSTRAINT fk_empleado_direccion FOREIGN KEY (id_direccion) REFERENCES direccion (id_direccion);

ALTER TABLE almacen
    ADD CONSTRAINT fk_almacen_empleado FOREIGN KEY (id_empleado_jefe) REFERENCES empleado (id_empleado),
    ADD CONSTRAINT fk_almacen_direccion FOREIGN KEY (id_direccion) REFERENCES direccion (id_direccion);