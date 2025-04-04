DELIMITER //

CREATE TRIGGER ActualizarTotalAlquileresEmpleado
AFTER INSERT ON alquiler
FOR EACH ROW
BEGIN
    -- Primero verificamos si la tabla de estadísticas existe
    -- Si no existe, la creamos
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables 
                   WHERE table_name = 'estadisticas_empleados') THEN
        CREATE TABLE estadisticas_empleados (
            id_empleado TINYINT UNSIGNED PRIMARY KEY,
            total_alquileres INT UNSIGNED DEFAULT 0,
            ultima_actualizacion TIMESTAMP,
            FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado)
        );
        
        -- Insertamos todos los empleados existentes con contador en 0
        INSERT INTO estadisticas_empleados (id_empleado, total_alquileres, ultima_actualizacion)
        SELECT id_empleado, 0, CURRENT_TIMESTAMP FROM empleado;
    END IF;
    
    -- Actualizamos el contador para el empleado
    UPDATE estadisticas_empleados
    SET 
        total_alquileres = total_alquileres + 1,
        ultima_actualizacion = CURRENT_TIMESTAMP
    WHERE id_empleado = NEW.id_empleado;
    
    -- Si el empleado no está en la tabla (improbable), lo insertamos
    IF ROW_COUNT() = 0 THEN
        INSERT INTO estadisticas_empleados (id_empleado, total_alquileres, ultima_actualizacion)
        VALUES (NEW.id_empleado, 1, CURRENT_TIMESTAMP);
    END IF;
END//

DELIMITER ;

DELIMITER //

CREATE TRIGGER AuditarActualizacionCliente
AFTER UPDATE ON cliente
FOR EACH ROW
BEGIN
    DECLARE cambios TEXT;
    
    -- Construimos un string con los campos modificados
    SET cambios = CONCAT(
        IF(OLD.nombre != NEW.nombre, CONCAT('nombre: ', OLD.nombre, ' → ', NEW.nombre, '; '), ''),
        IF(OLD.apellidos != NEW.apellidos, CONCAT('apellidos: ', OLD.apellidos, ' → ', NEW.apellidos, '; '), ''),
        IF(OLD.email != NEW.email, CONCAT('email: ', OLD.email, ' → ', NEW.email, '; '), ''),
        IF(OLD.activo != NEW.activo, CONCAT('activo: ', OLD.activo, ' → ', NEW.activo, '; '), ''),
        IF(OLD.id_almacen != NEW.id_almacen, CONCAT('almacen: ', OLD.id_almacen, ' → ', NEW.id_almacen, '; '), ''),
        IF(OLD.id_direccion != NEW.id_direccion, CONCAT('direccion: ', OLD.id_direccion, ' → ', NEW.id_direccion, '; '), '')
    );
    
    -- Solo registramos si hubo cambios reales
    IF cambios != '' THEN
        INSERT INTO auditoria_clientes (
            id_cliente, 
            accion, 
            datos_anteriores, 
            datos_nuevos, 
            usuario
        ) VALUES (
            NEW.id_cliente,
            'UPDATE',
            CONCAT(
                'Nombre: ', OLD.nombre, ' ', OLD.apellidos, 
                ' | Email: ', OLD.email,
                ' | Almacén: ', OLD.id_almacen,
                ' | Activo: ', IF(OLD.activo = 1, 'Sí', 'No')
            ),
            CONCAT(
                'Nombre: ', NEW.nombre, ' ', NEW.apellidos, 
                ' | Email: ', NEW.email,
                ' | Almacén: ', NEW.id_almacen,
                ' | Activo: ', IF(NEW.activo = 1, 'Sí', 'No')
            ),
            CURRENT_USER()
        );
    END IF;
END//

DELIMITER ;