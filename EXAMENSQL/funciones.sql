DELIMITER //

CREATE FUNCTION TotalIngresosCliente(ClienteID SMALLINT UNSIGNED, Anio INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);
    
    -- Calculamos el total de ingresos para el cliente en el año especificado
    SELECT IFNULL(SUM(p.total), 0) INTO total
    FROM pago p
    WHERE p.id_cliente = ClienteID
    AND YEAR(p.fecha_pago) = Anio;
    
    RETURN total;
END//

DELIMITER ;