CREATE TABLE Socios (
  id INT PRIMARY KEY IDENTITY(1, 1),
  nombre NVARCHAR(255),
  email NVARCHAR(255),
  fecha_ingreso DATE,
  estado NVARCHAR(255)
);
GO

CREATE TABLE Prestamos (
  id INT PRIMARY KEY IDENTITY(1, 1),
  socio_id INT,
  monto DECIMAL(10,2),
  tasa_interes DECIMAL(5,2),
  fecha_inicio DATE,
  plazo_meses INT,
  saldo_pendiente DECIMAL(10,2),
  estado NVARCHAR(255),
  fecha_ultimo_pago DATE
);
GO

CREATE TABLE Pagos (
  id INT PRIMARY KEY IDENTITY(1, 1),
  prestamo_id INT,
  fecha_pago DATE,
  monto_pagado DECIMAL(10,2)
);
GO

CREATE TABLE Bitacora (
  id INT PRIMARY KEY IDENTITY(1, 1),
  usuario NVARCHAR(255),
  accion NVARCHAR(255),
  tabla_afectada NVARCHAR(255),
  id_registro INT,
  fecha DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE ProyeccionIngresos (
  id INT PRIMARY KEY IDENTITY(1, 1),
  prestamo_id INT,
  socio_id INT,
  nombre_socio NVARCHAR(255),
  mes_proyectado DATE,
  monto_estimado DECIMAL(10,2)
);
GO

CREATE TABLE Roles (
  id INT PRIMARY KEY IDENTITY(1, 1),
  nombre_rol NVARCHAR(255)
);
GO

CREATE TABLE Usuarios (
  id INT PRIMARY KEY IDENTITY(1, 1),
  nombre_usuario NVARCHAR(255),
  rol_id INT
);
GO

CREATE TABLE Permisos (
  id INT PRIMARY KEY IDENTITY(1, 1),
  rol_id INT,
  tabla NVARCHAR(255),
  accion NVARCHAR(255)
);
GO

-- ------------------------------------------Llaves foráneas
ALTER TABLE Prestamos ADD FOREIGN KEY (socio_id) REFERENCES Socios(id);
GO

ALTER TABLE Pagos ADD FOREIGN KEY (prestamo_id) REFERENCES Prestamos(id);
GO

ALTER TABLE ProyeccionIngresos ADD FOREIGN KEY (prestamo_id) REFERENCES Prestamos(id);
GO

ALTER TABLE ProyeccionIngresos ADD FOREIGN KEY (socio_id) REFERENCES Socios(id);
GO

ALTER TABLE Usuarios ADD FOREIGN KEY (rol_id) REFERENCES Roles(id);
GO

ALTER TABLE Permisos ADD FOREIGN KEY (rol_id) REFERENCES Roles(id);
GO

USE master;
GO
-----------------------------------------Crear sesiones--------
/*
 --Crear inicio de sesión y dar acceso a la base de datos para admin_db
CREATE LOGIN admin_db WITH PASSWORD = 'AdminUMG*';
GO
USE ProyectoFianalDBll;
CREATE USER admin_db FOR LOGIN admin_db;
GO

------Crear inicio de sesión y dar acceso a la base de datos para cajero_db----
CREATE LOGIN cajero_db WITH PASSWORD = 'CajeroUMG*';
GO
USE ProyectoFianalDBll;
CREATE USER cajero_db FOR LOGIN cajero_db;
GO

-------Crear inicio de sesión y dar acceso a la base de datos para lector_db---------
CREATE LOGIN lector_db WITH PASSWORD = 'LectorUMG*';
GO
USE ProyectoFianalDBll;
CREATE USER lector_db FOR LOGIN lector_db;
GO
*/

---------------------------------Crear Usuarios Contenidos--------

--Crear usuario para admin_db
USE ProyectoFianalDBll;
CREATE USER admin_db WITH PASSWORD = 'UMG/2025/adm';
GO

------Crear usuario para cajero_db----
USE ProyectoFianalDBll;
CREATE USER cajero_db WITH PASSWORD = 'UMG/2025/caj';
GO

-------Crear usuario para lector_db---------
USE ProyectoFianalDBll;
CREATE USER lector_db WITH PASSWORD = 'UMG/2025/lec';
GO


-----------------------------------------------crear los roles---
CREATE ROLE rol_admin;
CREATE ROLE rol_cajero;
CREATE ROLE rol_lector;

-----------------------------------------------Asignar usuarios a los roles /////////(inicios de sesión).---
ALTER ROLE rol_admin ADD MEMBER admin_db;
ALTER ROLE rol_cajero ADD MEMBER cajero_db;
ALTER ROLE rol_lector ADD MEMBER lector_db;

-----------------------------------------------Asignar permios a los roles ------
--asignar permisos al administrador---
GRANT CONTROL ON DATABASE::ProyectoFianalDBll TO rol_admin;

--asignar permisos al cajero----
GRANT SELECT, INSERT, UPDATE ON dbo.Socios TO rol_cajero;
GRANT SELECT, INSERT, UPDATE ON dbo.Prestamos TO rol_cajero;
GRANT SELECT, INSERT, UPDATE ON dbo.Pagos TO rol_cajero;

--------------Se crea las vistas para el lector---
-- Vista: préstamos activos
CREATE VIEW vw_prestamos_activos AS
SELECT * FROM Prestamos
WHERE estado = 'VIGENTE' AND saldo_pendiente > 0;

-- Vista: socios morosos
CREATE VIEW vw_socios_morosos AS
SELECT s.id, s.nombre, p.id AS prestamo_id, p.saldo_pendiente
FROM Socios s
JOIN Prestamos p ON s.id = p.socio_id
WHERE p.estado = 'EN MORA';

-- Vista: historial de pagos
CREATE VIEW vw_historial_pagos AS
SELECT pa.id AS pago_id, s.nombre AS socio, pa.fecha_pago, pa.monto_pagado
FROM Pagos pa
JOIN Prestamos p ON pa.prestamo_id = p.id
JOIN Socios s ON p.socio_id = s.id;

-- Vista: bitácora de acciones
CREATE VIEW vw_bitacora_acciones AS
SELECT TOP 100 * FROM Bitacora
ORDER BY fecha DESC;

 --se da los permisos al lector---
GRANT SELECT ON dbo.vw_prestamos_activos TO rol_lector;
GRANT SELECT ON dbo.vw_socios_morosos TO rol_lector;
GRANT SELECT ON dbo.vw_historial_pagos TO rol_lector;
GRANT SELECT ON dbo.vw_bitacora_acciones TO rol_lector;


----------------------------------------------haciendo las primeras pruebas

--insertamos un socio---
INSERT INTO Socios (nombre, email, fecha_ingreso, estado)
VALUES ('Marino Velasquez', 'vidalgmarino@gmail.com', '2024-01-10', 'ACTIVO');

--Crear un préstamo para el socio--
INSERT INTO Prestamos (socio_id, monto, tasa_interes, fecha_inicio, plazo_meses, saldo_pendiente, estado)
VALUES (1, 1000.00, 0.10, '2024-02-01', 12, 1000.00, 'VIGENTE');

INSERT INTO Prestamos (socio_id, monto, tasa_interes, fecha_inicio, plazo_meses, saldo_pendiente, estado)
VALUES (1, 1000.00, 0.10, '2024-02-01', 12, 1000.00, 'VIGENTE');


--Registro un pago para el socio--
INSERT INTO Pagos (prestamo_id, fecha_pago, monto_pagado)
VALUES (1, '2024-03-01', 200.00);

--Verifico los prestamos activos--
SELECT * FROM vw_prestamos_activos;

--Ver el historial de pagos---
SELECT * FROM vw_historial_pagos;

--Simular una acción para la bitácora---
INSERT INTO Bitacora (usuario, accion, tabla_afectada, id_registro, fecha)
VALUES ('admin_db', 'INSERTAR', 'Prestamos', 1, GETDATE());

--ver el historial de las bitacoras--
SELECT * FROM vw_bitacora_acciones;

-----------------------------------Procedimientos almacenados y funciones--------------------



--registrar un préstamo con su cálculo automático de saldo pendiente.--
CREATE PROCEDURE sp_crear_prestamo
 @socio_id INT,
 @monto DECIMAL(10,2),
 @tasa DECIMAL(5,2),
 @plazo INT
AS
BEGIN
 DECLARE @saldo_total DECIMAL(10,2);
 SET @saldo_total = @monto + (@monto * @tasa);

 INSERT INTO Prestamos (socio_id, monto, tasa_interes, fecha_inicio, plazo_meses, saldo_pendiente, estado)
 VALUES (@socio_id, @monto, @tasa, GETDATE(), @plazo, @saldo_total, 'VIGENTE');

 INSERT INTO Bitacora (usuario, accion, tabla_afectada, id_registro)
 VALUES (USER, 'INSERTAR', 'Prestamos', SCOPE_IDENTITY());
END;
GO



--registrar un pago y actualizar automáticamente el préstamo relacionado.--

CREATE PROCEDURE sp_registrar_pago
  @prestamo_id INT,
  @monto DECIMAL(10,2)
AS
BEGIN
  INSERT INTO Pagos (prestamo_id, fecha_pago, monto_pagado)
  VALUES (@prestamo_id, GETDATE(), @monto);

  INSERT INTO Bitacora (usuario, accion, tabla_afectada, id_registro)
  VALUES (SYSTEM_USER, 'INSERTAR', 'Pagos', SCOPE_IDENTITY());

  EXEC sp_recalcular_saldo @prestamo_id;

  UPDATE Prestamos
  SET fecha_ultimo_pago = GETDATE()
  WHERE id = @prestamo_id;
END;
GO

---llevar el control actualizado del saldo del préstamo después de cada pago.--
CREATE PROCEDURE sp_recalcular_saldo
  @prestamo_id INT
AS
BEGIN
  DECLARE @total_pagado DECIMAL(10,2);

  SELECT @total_pagado = ISNULL(SUM(monto_pagado), 0)
  FROM Pagos
  WHERE prestamo_id = @prestamo_id;

  UPDATE Prestamos
  SET saldo_pendiente = monto + (monto * tasa_interes) - @total_pagado
  WHERE id = @prestamo_id;

  IF EXISTS (
    SELECT 1 FROM Prestamos
    WHERE id = @prestamo_id AND saldo_pendiente <= 0
  )
  BEGIN
    UPDATE Prestamos
    SET estado = 'PAGADO'
    WHERE id = @prestamo_id;
  END
END;
GO

--DROP PROCEDURE sp_generar_proyeccion;--


CREATE PROCEDURE sp_generar_proyeccion
  @meses INT
AS
BEGIN
  DECLARE @prestamo_id INT, @socio_id INT, @nombre_socio NVARCHAR(255);
  DECLARE @saldo_pendiente DECIMAL(10,2), @cuota_mensual DECIMAL(10,2);
  DECLARE @contador_meses INT, @fecha_proyectada DATE;

  -- Declara el cursor para recorrer los préstamos vigentes
  DECLARE cursor_prestamos CURSOR FOR
    SELECT p.id, s.id, s.nombre, p.saldo_pendiente, p.plazo_meses
    FROM Prestamos p
    JOIN Socios s ON p.socio_id = s.id
    WHERE p.estado = 'VIGENTE';

  -- Abre el cursor
  OPEN cursor_prestamos;

  -- Obtiene el primer préstamo
  FETCH NEXT FROM cursor_prestamos INTO @prestamo_id, @socio_id, @nombre_socio, @saldo_pendiente, @contador_meses;

  -- Itera sobre los préstamos
  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- Calcula la cuota mensual (aquí se asume cuotas fijas)
    SET @cuota_mensual = @saldo_pendiente / @contador_meses;
    SET @contador_meses = 1;

    -- Genera las proyecciones para el préstamo actual
    WHILE @contador_meses <= @meses AND @contador_meses <= 12 -- Limitado a 12 meses para no exceder un año
    BEGIN
      -- Calcula la fecha de proyección
      SET @fecha_proyectada = DATEADD(MONTH, @contador_meses, GETDATE());

      -- Inserta la proyección en la tabla
      INSERT INTO ProyeccionIngresos (prestamo_id, socio_id, nombre_socio, mes_proyectado, monto_estimado)
      VALUES (@prestamo_id, @socio_id, @nombre_socio, @fecha_proyectada, @cuota_mensual);

      -- Incrementa el contador de meses
      SET @contador_meses = @contador_meses + 1;
    END

    -- Registra la acción en la bitácora
    INSERT INTO Bitacora (usuario, accion, tabla_afectada, id_registro)
    VALUES (SYSTEM_USER, 'PROYECCION', 'ProyeccionIngresos', @prestamo_id);

    -- Obtiene el siguiente préstamo
    FETCH NEXT FROM cursor_prestamos INTO @prestamo_id, @socio_id, @nombre_socio, @saldo_pendiente, @contador_meses;
  END

 
  CLOSE cursor_prestamos;
  DEALLOCATE cursor_prestamos;
END;
GO



--obtener rápido cuánto se debe pagar con interés. Se puede usar en reportes o SP.--
CREATE FUNCTION fn_calcular_interes (
  @monto DECIMAL(10,2),
  @tasa DECIMAL(5,2),
  @plazo INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
  RETURN @monto + (@monto * @tasa);
END;

--saber en qué estado está un préstamo: VIGENTE, PAGADO o EN MORA.--
CREATE FUNCTION fn_estado_prestamo (
  @prestamo_id INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
  DECLARE @estado NVARCHAR(50);
  SELECT @estado = estado FROM Prestamos WHERE id = @prestamo_id;
  RETURN @estado;
END;


--------------------------------pruebas------------------
--Crear un préstamo con el procedimiento---
EXEC sp_crear_prestamo 
  @socio_id = 1, 
  @monto = 1200.00, 
  @tasa = 0.10, 
  @plazo = 12;

  --Registrar un pago--
  EXEC sp_registrar_pago 
  @prestamo_id = 1, 
  @monto = 200.00;

  --Generar proyección de ingresos para los próximos 6 meses--
  EXEC sp_generar_proyeccion @meses = 6;

  -----------------------verificando------------------------
  --Verificar que el pago se registró y el saldo se actualizó
SELECT * FROM Pagos WHERE prestamo_id = 1;
SELECT * FROM Prestamos WHERE id = 1;

--Verificar el estado actual del préstamo--
SELECT dbo.fn_estado_prestamo(1) AS Estado;

--Consultar las proyecciones generadas--
SELECT * FROM ProyeccionIngresos WHERE prestamo_id = 1;



-------------------------------------------------------triggers y cursor-------------------------------  


-- Evita pagos duplicados en la misma fecha para el mismo préstamo
CREATE TRIGGER trg_prevenir_pagos_duplicados
ON Pagos
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Pagos p
        JOIN inserted i ON p.prestamo_id = i.prestamo_id AND p.fecha_pago = i.fecha_pago
    )
    BEGIN
        RAISERROR('Ya existe un pago para ese préstamo en esa fecha.', 16, 1);
        RETURN;
    END
    INSERT INTO Pagos (prestamo_id, fecha_pago, monto_pagado)
    SELECT prestamo_id, fecha_pago, monto_pagado FROM inserted;
END
GO

-- Evita registrar pagos en préstamos en mora
CREATE TRIGGER trg_bloquear_prestamo_en_mora
ON Pagos
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Prestamos p ON i.prestamo_id = p.id
        WHERE p.estado = 'EN MORA'
    )
    BEGIN
        RAISERROR('No se puede registrar pago en un préstamo en mora.', 16, 1);
        ROLLBACK;
    END
END
GO

-- Guarda en bitácora los préstamos eliminados
CREATE TRIGGER trg_log_eliminacion_prestamo
ON Prestamos
AFTER DELETE
AS
BEGIN
    INSERT INTO Bitacora (usuario, accion, tabla_afectada, id_registro)
    SELECT SYSTEM_USER, 'ELIMINACION', 'Prestamos', id FROM deleted;
END
GO

-- Actualiza automáticamente el estado de préstamo según saldo
CREATE TRIGGER trg_actualizar_estado_pago
ON Pagos
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET estado = CASE 
                    WHEN p.saldo_pendiente <= 0 THEN 'CANCELADO'
                    ELSE p.estado
                 END
    FROM Prestamos p
    JOIN inserted i ON i.prestamo_id = p.id;
END
GO

-- Registra la fecha del último pago al hacer uno nuevo
CREATE TRIGGER trg_actualizar_ultimo_pago
ON Pagos
AFTER INSERT
AS
BEGIN
    UPDATE Prestamos
    SET fecha_ultimo_pago = i.fecha_pago
    FROM Prestamos p
    JOIN inserted i ON p.id = i.prestamo_id;
END
GO



----------------------
-- Añadir la columna 'contrasena' a la tabla Usuarios si no existe
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Usuarios') AND name = 'contrasena')
BEGIN
    ALTER TABLE Usuarios
    ADD contrasena NVARCHAR(255) NOT NULL DEFAULT ''; -- NVARCHAR(255) es ideal para hashes de contraseñas.
END;
GO

DECLARE @admin_rol_id INT = (SELECT id FROM Roles WHERE nombre_rol = 'rol_admin');
DECLARE @cajero_rol_id INT = (SELECT id FROM Roles WHERE nombre_rol = 'rol_cajero');
DECLARE @lector_rol_id INT = (SELECT id FROM Roles WHERE nombre_rol = 'rol_lector');

MERGE INTO Usuarios AS target
USING (VALUES
    ('admin_db', 'UMG/2025/adm', @admin_rol_id), -- Contraseña en texto plano
    ('cajero_db', 'UMG/2025/caj', @cajero_rol_id), -- Contraseña en texto plano
    ('lector_db', 'UMG/2025/lec', @lector_rol_id)  -- Contraseña en texto plano
) AS source (nombre_usuario, contrasena, rol_id)
ON target.nombre_usuario = source.nombre_usuario
WHEN MATCHED THEN
    UPDATE SET target.contrasena = source.contrasena, target.rol_id = source.rol_id
WHEN NOT MATCHED BY TARGET THEN
    INSERT (nombre_usuario, contrasena, rol_id) VALUES (source.nombre_usuario, source.contrasena, source.rol_id);
GO


USE ProyectoFianalDBll;
GO

DECLARE @admin_rol_id INT = (SELECT id FROM Roles WHERE nombre_rol = 'rol_admin');
DECLARE @cajero_rol_id INT = (SELECT id FROM Roles WHERE nombre_rol = 'rol_cajero');
DECLARE @lector_rol_id INT = (SELECT id FROM Roles WHERE nombre_rol = 'rol_lector');

SELECT
    @admin_rol_id AS AdminRolID,
    @cajero_rol_id AS CajeroRolID,
    @lector_rol_id AS LectorRolID;
GO

-- Asegurarse de que los roles existan (si es necesario)
INSERT INTO Roles (nombre_rol)
SELECT 'rol_admin' WHERE NOT EXISTS (SELECT 1 FROM Roles WHERE nombre_rol = 'rol_admin');
INSERT INTO Roles (nombre_rol)
SELECT 'rol_cajero' WHERE NOT EXISTS (SELECT 1 FROM Roles WHERE nombre_rol = 'rol_cajero');
INSERT INTO Roles (nombre_rol)
SELECT 'rol_lector' WHERE NOT EXISTS (SELECT 1 FROM Roles WHERE nombre_rol = 'rol_lector');
GO



CREATE TRIGGER trg_validar_prestamo
ON Prestamos
INSTEAD OF INSERT
AS
BEGIN
  IF EXISTS (
    SELECT 1 FROM inserted
    WHERE tasa_interes = 0 AND plazo_meses = 0
  )
  BEGIN
    RAISERROR('No se permite préstamo con 0% de interés y 0 meses de plazo.', 16, 1);
    RETURN;
  END

  INSERT INTO Prestamos (socio_id, monto, tasa_interes, fecha_inicio, plazo_meses, saldo_pendiente, estado, fecha_ultimo_pago)
  SELECT socio_id, monto, tasa_interes, fecha_inicio, plazo_meses, saldo_pendiente, estado, fecha_ultimo_pago
  FROM inserted;
END
GO
