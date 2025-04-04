-- 1. Encuentra el cliente que ha realizado la mayor cantidad de alquileres en los últimos 6 meses.
SELECT 
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellidos) AS nombre_cliente,
    COUNT(a.id_alquiler) AS total_alquileres
FROM 
    cliente c
JOIN 
    alquiler a ON c.id_cliente = a.id_cliente
WHERE 
    a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY 
    c.id_cliente, c.nombre, c.apellidos
ORDER BY 
    total_alquileres DESC
LIMIT 1;

-- 2. Lista las cinco películas más alquiladas durante el último año.
SELECT 
    p.id_pelicula,
    p.titulo,
    COUNT(a.id_alquiler) AS veces_alquilada
FROM 
    pelicula p
JOIN 
    inventario i ON p.id_pelicula = i.id_pelicula
JOIN 
    alquiler a ON i.id_inventario = a.id_inventario
WHERE 
    a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY 
    p.id_pelicula, p.titulo
ORDER BY 
    veces_alquilada DESC
LIMIT 5;

-- 3. Obtén el total de ingresos y la cantidad de alquileres realizados por cada categoría de película.
SELECT 
    c.nombre AS categoria,
    COUNT(a.id_alquiler) AS total_alquileres,
    SUM(p.total) AS ingresos_totales
FROM 
    categoria c
JOIN 
    pelicula_categoria pc ON c.id_categoria = pc.id_categoria
JOIN 
    pelicula pel ON pc.id_pelicula = pel.id_pelicula
JOIN 
    inventario i ON pel.id_pelicula = i.id_pelicula
JOIN 
    alquiler a ON i.id_inventario = a.id_inventario
JOIN 
    pago p ON a.id_alquiler = p.id_alquiler
GROUP BY 
    c.id_categoria, c.nombre
ORDER BY 
    ingresos_totales DESC;

-- 4. Calcula el número total de clientes que han realizado alquileres por cada idioma disponible en un mes específico.
-- Suponiendo que queremos datos de febrero de 2022
SELECT 
    i.nombre AS idioma,
    COUNT(DISTINCT c.id_cliente) AS total_clientes
FROM 
    idioma i
JOIN 
    pelicula p ON i.id_idioma = p.id_idioma
JOIN 
    inventario inv ON p.id_pelicula = inv.id_pelicula
JOIN 
    alquiler a ON inv.id_inventario = a.id_inventario
JOIN 
    cliente c ON a.id_cliente = c.id_cliente
WHERE 
    MONTH(a.fecha_alquiler) = 2 AND YEAR(a.fecha_alquiler) = 2022
GROUP BY 
    i.id_idioma, i.nombre
ORDER BY 
    total_clientes DESC;

-- 5. Encuentra a los clientes que han alquilado todas las películas de una misma categoría.
-- Usando la técnica de division relacional con NOT EXISTS
SELECT 
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellidos) AS nombre_cliente,
    cat.id_categoria,
    cat.nombre AS nombre_categoria
FROM 
    cliente c
CROSS JOIN 
    categoria cat
WHERE NOT EXISTS (
    -- Películas de la categoría que el cliente NO ha alquilado
    SELECT 1
    FROM pelicula_categoria pc
    JOIN pelicula p ON pc.id_pelicula = p.id_pelicula
    WHERE pc.id_categoria = cat.id_categoria
    AND NOT EXISTS (
        SELECT 1
        FROM alquiler a
        JOIN inventario i ON a.id_inventario = i.id_inventario
        WHERE i.id_pelicula = p.id_pelicula
        AND a.id_cliente = c.id_cliente
    )
)
AND EXISTS (
    -- Verificar que la categoría tiene al menos una película
    SELECT 1
    FROM pelicula_categoria pc
    WHERE pc.id_categoria = cat.id_categoria
)
ORDER BY 
    cat.nombre, c.id_cliente;

-- 6. Lista las tres ciudades con más clientes activos en el último trimestre.
SELECT 
    ci.nombre AS ciudad,
    COUNT(DISTINCT c.id_cliente) AS total_clientes_activos
FROM 
    ciudad ci
JOIN 
    direccion d ON ci.id_ciudad = d.id_ciudad
JOIN 
    cliente c ON d.id_direccion = c.id_direccion
JOIN 
    alquiler a ON c.id_cliente = a.id_cliente
WHERE 
    c.activo = 1
    AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY 
    ci.id_ciudad, ci.nombre
ORDER BY 
    total_clientes_activos DESC
LIMIT 3;

-- 7. Muestra las cinco categorías con menos alquileres registrados en el último año.
SELECT 
    c.nombre AS categoria,
    COUNT(a.id_alquiler) AS total_alquileres
FROM 
    categoria c
LEFT JOIN 
    pelicula_categoria pc ON c.id_categoria = pc.id_categoria
LEFT JOIN 
    pelicula p ON pc.id_pelicula = p.id_pelicula
LEFT JOIN 
    inventario i ON p.id_pelicula = i.id_pelicula
LEFT JOIN 
    alquiler a ON i.id_inventario = a.id_inventario AND a.fecha_alquiler >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY 
    c.id_categoria, c.nombre
ORDER BY 
    total_alquileres ASC
LIMIT 5;

-- 8. Calcula el promedio de días que un cliente tarda en devolver las películas alquiladas.
SELECT 
    AVG(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS promedio_dias_devolucion
FROM 
    alquiler a
WHERE 
    a.fecha_devolucion IS NOT NULL;

-- Promedio por cliente
SELECT 
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.apellidos) AS nombre_cliente,
    AVG(DATEDIFF(a.fecha_devolucion, a.fecha_alquiler)) AS promedio_dias_devolucion,
    COUNT(a.id_alquiler) AS total_alquileres
FROM 
    cliente c
JOIN 
    alquiler a ON c.id_cliente = a.id_cliente
WHERE 
    a.fecha_devolucion IS NOT NULL
GROUP BY 
    c.id_cliente, c.nombre, c.apellidos
ORDER BY 
    promedio_dias_devolucion DESC;

-- 9. Encuentra los cinco empleados que gestionaron más alquileres en la categoría de Acción.
SELECT 
    e.id_empleado,
    CONCAT(e.nombre, ' ', e.apellidos) AS nombre_empleado,
    COUNT(a.id_alquiler) AS total_alquileres_accion
FROM 
    empleado e
JOIN 
    alquiler a ON e.id_empleado = a.id_empleado
JOIN 
    inventario i ON a.id_inventario = i.id_inventario
JOIN 
    pelicula p ON i.id_pelicula = p.id_pelicula
JOIN 
    pelicula_categoria pc ON p.id_pelicula = pc.id_pelicula
JOIN 
    categoria c ON pc.id_categoria = c.id_categoria
WHERE 
    c.nombre = 'Acción'
GROUP BY 
    e.id_empleado, e.nombre, e.apellidos
ORDER BY 
    total_alquileres_accion DESC
LIMIT 5;

-- 10. Genera un informe de los clientes con alquileres más recurrentes.
WITH frecuencia_alquiler AS (
    SELECT 
        c.id_cliente,
        CONCAT(c.nombre, ' ', c.apellidos) AS nombre_cliente,
        COUNT(a.id_alquiler) AS total_alquileres,
        MIN(a.fecha_alquiler) AS primera_fecha,
        MAX(a.fecha_alquiler) AS ultima_fecha,
        DATEDIFF(MAX(a.fecha_alquiler), MIN(a.fecha_alquiler)) AS periodo_dias
    FROM 
        cliente c
    JOIN 
        alquiler a ON c.id_cliente = a.id_cliente
    GROUP BY 
        c.id_cliente, c.nombre, c.apellidos
    HAVING 
        COUNT(a.id_alquiler) > 1
        AND DATEDIFF(MAX(a.fecha_alquiler), MIN(a.fecha_alquiler)) > 0
)
SELECT 
    id_cliente,
    nombre_cliente,
    total_alquileres,
    primera_fecha,
    ultima_fecha,
    periodo_dias,
    total_alquileres / (periodo_dias / 30.0) AS promedio_alquileres_por_mes
FROM 
    frecuencia_alquiler
ORDER BY 
    promedio_alquileres_por_mes DESC
LIMIT 10;
