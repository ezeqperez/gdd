USE GD1C2018;

-- Create schema
BEGIN TRANSACTION
	IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'MAX_TURBO')
	EXEC sys.sp_executesql N'CREATE SCHEMA [MAX_TURBO]'
	
COMMIT

-- Drop tables
if object_id('MAX_TURBO.hotel') is not null
  drop table MAX_TURBO.hotel;
if object_id('MAX_TURBO.mantenimiento_hotel') is not null
  drop table MAX_TURBO.mantenimiento_hotel;
if object_id('MAX_TURBO.hotel_regimen') is not null
  drop table MAX_TURBO.hotel_regimen;
if object_id('MAX_TURBO.usuario_hotel') is not null
  drop table MAX_TURBO.usuario_hotel;
if object_id('MAX_TURBO.regimen') is not null
  drop table MAX_TURBO.regimen;
if object_id('MAX_TURBO.reserva') is not null
  drop table MAX_TURBO.reserva;
if object_id('MAX_TURBO.reserva_habitacion') is not null
  drop table MAX_TURBO.reserva_habitacion;
if object_id('MAX_TURBO.habitacion') is not null
  drop table MAX_TURBO.habitacion;
if object_id('MAX_TURBO.tipo_habitacion') is not null
  drop table MAX_TURBO.tipo_habitacion;
if object_id('MAX_TURBO.usuario') is not null
  drop table MAX_TURBO.usuario;
if object_id('MAX_TURBO.usuario_rol') is not null
  drop table MAX_TURBO.usuario_rol;
if object_id('MAX_TURBO.rol') is not null
  drop table MAX_TURBO.rol;
if object_id('MAX_TURBO.funcionalidad_rol') is not null
  drop table MAX_TURBO.funcionalidad_rol;
if object_id('MAX_TURBO.funcionalidad') is not null
  drop table MAX_TURBO.funcionalidad;
if object_id('MAX_TURBO.reserva_cancelada') is not null
  drop table MAX_TURBO.reserva_cancelada;
if object_id('MAX_TURBO.estado_reserva') is not null
  drop table MAX_TURBO.estado_reserva;
if object_id('MAX_TURBO.cliente') is not null
  drop table MAX_TURBO.cliente;
if object_id('MAX_TURBO.estadia_cliente') is not null
  drop table MAX_TURBO.estadia_cliente;
if object_id('MAX_TURBO.factura_item') is not null
  drop table MAX_TURBO.factura_item;
if object_id('MAX_TURBO.factura') is not null
  drop table MAX_TURBO.factura;
if object_id('MAX_TURBO.medio_pago') is not null
  drop table MAX_TURBO.medio_pago;
if object_id('MAX_TURBO.estadia') is not null
  drop table MAX_TURBO.estadia;
if object_id('MAX_TURBO.consumible') is not null
  drop table MAX_TURBO.consumible;
if object_id('MAX_TURBO.consumible_estadia') is not null
  drop table MAX_TURBO.consumible_estadia;
if object_id('MAX_TURBO.tarjeta_credito') is not null
  drop table MAX_TURBO.tarjeta_credito;
/*-----------------------------------------------*/

-- Create tables
CREATE TABLE MAX_TURBO.usuario (
	id int PRIMARY KEY IDENTITY,
	username nvarchar(50) NOT NULL CONSTRAINT UQ_usuario_username UNIQUE,
	[password] char(64) NOT NULL,
	nombre nvarchar(255) NOT NULL,
	apellido nvarchar(255) NOT NULL,
	tipo_documento nvarchar(10) NOT NULL,
	nro_documento numeric(18,0) NOT NULL,
	email nvarchar(255) NOT NULL CONSTRAINT UQ_usuario_email UNIQUE,
	telefono nvarchar(20),
	direccion_calle nvarchar(255),
	direccion_nro numeric(18,0),
	direccion_piso numeric(18,0),
	direccion_depto nvarchar(50),
	direccion_ciudad nvarchar(255),
	direccion_pais nvarchar(255),
	fecha_nacimiento datetime,
	activo bit CONSTRAINT DF_usuario_activo DEFAULT 1,
	intentos_fallidos tinyint,
	CONSTRAINT UQ_usuario UNIQUE (tipo_documento, nro_documento)
)
GO

CREATE TABLE MAX_TURBO.rol (
	id int PRIMARY KEY IDENTITY,
	nombre nvarchar(255) NOT NULL CONSTRAINT UQ_rol_nombre UNIQUE,
	activo bit CONSTRAINT DF_rol_activo DEFAULT 1
)
GO

CREATE TABLE MAX_TURBO.usuario_rol (
	usuario_id int FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	rol_id int FOREIGN KEY REFERENCES MAX_TURBO.rol(id),
	PRIMARY KEY (usuario_id, rol_id)
)
GO

CREATE TABLE MAX_TURBO.funcionalidad (
	id int PRIMARY KEY IDENTITY,
	codigo nvarchar(255) NOT NULL CONSTRAINT UQ_funcionalidad_codigo UNIQUE,
	nombre nvarchar(255) NOT NULL
)
GO

CREATE TABLE MAX_TURBO.funcionalidad_rol (
	rol_id int FOREIGN KEY REFERENCES MAX_TURBO.rol(id),
	funcionalidad_id int FOREIGN KEY REFERENCES MAX_TURBO.funcionalidad(id),
	PRIMARY KEY (rol_id, funcionalidad_id)
)
GO

CREATE TABLE MAX_TURBO.hotel (
	id int PRIMARY KEY IDENTITY,
	nombre nvarchar(255) NOT NULL CONSTRAINT UQ_hotel_nombre UNIQUE,
	email nvarchar(255) NOT NULL,
	telefono nvarchar(20),
	direccion_calle nvarchar(255) NOT NULL,
	direccion_nro numeric(18,0) NOT NULL,
	estrellas numeric(18,0) NOT NULL,
	recargo_estrellas numeric(18,0) NOT NULL,
	ciudad nvarchar(255) NOT NULL,
	pais nvarchar(255) NOT NULL,
	fecha_creacion datetime NOT NULL CONSTRAINT DF_hotel_fecha_creacion DEFAULT CURRENT_TIMESTAMP,
	activo bit CONSTRAINT DF_hotel_activo DEFAULT 1
)
GO

CREATE TABLE MAX_TURBO.usuario_hotel (
	usuario_id int FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	hotel_id int FOREIGN KEY REFERENCES MAX_TURBO.hotel(id),
	PRIMARY KEY (usuario_id, hotel_id)
)
GO

CREATE TABLE MAX_TURBO.mantenimiento_hotel (
	id int PRIMARY KEY IDENTITY,
	fecha_inicio datetime NOT NULL,
	fecha_fin datetime NOT NULL,
	hotel_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.hotel(id),
	tareas_descripcion nvarchar(1000)
)
GO

CREATE TABLE MAX_TURBO.tipo_habitacion (
	id int PRIMARY KEY IDENTITY,
	codigo numeric(18,0) NOT NULL CONSTRAINT UQ_habitacion_codigo UNIQUE,
	nombre nvarchar(255) NOT NULL,
	porcentaje numeric(18,2) NOT NULL
)
GO

CREATE TABLE MAX_TURBO.habitacion (
	id int PRIMARY KEY IDENTITY,
	numero numeric(18,0) NOT NULL,
	piso numeric(18,0) NOT NULL,
	frente nvarchar(50) NOT NULL CONSTRAINT CK_habitacion_frente CHECK (frente IN('S', 'N')),
	descripcion nvarchar(255),
	activo bit CONSTRAINT DF_habitacion_activo DEFAULT 1,
	tipo_habitacion_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.habitacion(id),
	hotel_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.hotel(id),
	CONSTRAINT UQ_habitacion UNIQUE (numero, piso, hotel_id)
)
GO

CREATE TABLE MAX_TURBO.regimen (
	id int PRIMARY KEY IDENTITY,
	codigo numeric(18,0) NOT NULL CONSTRAINT UQ_regimen_codigo UNIQUE,
	precio numeric(18,2) NOT NULL,
	descripcion nvarchar(255),
	activo bit CONSTRAINT DF_regimen_activo DEFAULT 1
)
GO

CREATE TABLE MAX_TURBO.hotel_regimen (
	hotel_id int FOREIGN KEY REFERENCES MAX_TURBO.hotel(id),
	regimen_id int FOREIGN KEY REFERENCES MAX_TURBO.regimen(id),
	PRIMARY KEY (hotel_id, regimen_id)
)
GO

CREATE TABLE MAX_TURBO.cliente (
	id int PRIMARY KEY IDENTITY,
	nombre nvarchar(255) NOT NULL,
	apellido nvarchar(255) NOT NULL,
	tipo_documento nvarchar(10) NOT NULL,
	nro_documento numeric(18,0) NOT NULL,
	activo bit CONSTRAINT DF_cliente_activo DEFAULT 1,
	email nvarchar(255) NOT NULL,
	telefono nvarchar(20),
	direccion_calle nvarchar(255),
	direccion_nro numeric(18,0),
	direccion_piso numeric(18,0),
	direccion_depto nvarchar(50),
	direccion_ciudad nvarchar(255),
	direccion_pais nvarchar(255),
	nacionalidad nvarchar(255),
	fecha_nacimiento datetime
)
GO

CREATE TABLE MAX_TURBO.estado_reserva (
	id int PRIMARY KEY IDENTITY,
	nombre nvarchar(255) NOT NULL CONSTRAINT UQ_estado_reserva_nombre UNIQUE
)
GO

CREATE TABLE MAX_TURBO.reserva (
	id int PRIMARY KEY IDENTITY,
	estado_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.estado_reserva(id),
	fecha_creacion datetime NOT NULL CONSTRAINT DF_reserva_fecha_creacion DEFAULT CURRENT_TIMESTAMP,
	fecha_desde datetime NOT NULL,
	fecha_hasta datetime NOT NULL,
	codigo numeric(18,0),
	regimen_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.regimen(id),
	usuario_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	cliente_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.cliente(id),
	cantidad_personas tinyint CONSTRAINT DF_reserva_cantidad_personas DEFAULT 1,
	hotel_id int FOREIGN KEY REFERENCES MAX_TURBO.hotel(id),
)
GO

CREATE TABLE MAX_TURBO.reserva_habitacion (
	reserva_id int FOREIGN KEY REFERENCES MAX_TURBO.reserva(id),
	habitacion_id int FOREIGN KEY REFERENCES MAX_TURBO.habitacion(id),
	PRIMARY KEY (reserva_id, habitacion_id)
)
GO

CREATE TABLE MAX_TURBO.reserva_cancelada (
	id int PRIMARY KEY IDENTITY,
	reserva_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.reserva(id) CONSTRAINT UQ_reserva_cancelada UNIQUE,
	usuario_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	fecha datetime NOT NULL,
	motivo nvarchar(255)
)
GO

CREATE TABLE MAX_TURBO.estadia (
	id int PRIMARY KEY IDENTITY,
	ingreso_fecha datetime NOT NULL,
	ingreso_usuario_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	egreso_fecha datetime NOT NULL,
	egreso_usuario_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	reserva_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.reserva(id) CONSTRAINT UQ_estadia UNIQUE,
)
GO

CREATE TABLE MAX_TURBO.estadia_cliente (
	estadia_id int FOREIGN KEY REFERENCES MAX_TURBO.estadia(id),
	cliente_id int FOREIGN KEY REFERENCES MAX_TURBO.cliente(id),
	PRIMARY KEY (estadia_id, cliente_id)
)
GO

CREATE TABLE MAX_TURBO.consumible (
	id int PRIMARY KEY IDENTITY,
	nombre nvarchar(255) NOT NULL,
	precio numeric(18,2) NOT NULL,
	codigo numeric(18,0) NOT NULL CONSTRAINT UQ_consumible_codigo UNIQUE
)
GO

CREATE TABLE MAX_TURBO.consumible_estadia (
	consumible_id int FOREIGN KEY REFERENCES MAX_TURBO.consumible(id),
	estadia_id int FOREIGN KEY REFERENCES MAX_TURBO.estadia(id),
	unidades smallint NOT NULL,
	PRIMARY KEY (consumible_id, estadia_id)
)
GO

CREATE TABLE MAX_TURBO.tarjeta_credito (
	id int PRIMARY KEY IDENTITY,
	titular nvarchar(255) NOT NULL,
	numero nvarchar(16) NOT NULL,
	caducidad nvarchar(6) NOT NULL,
	cvv nvarchar(4) NOT NULL
	CONSTRAINT UQ_tarjeta_credito UNIQUE (numero, caducidad)
)
GO

CREATE TABLE MAX_TURBO.medio_pago (
	id int PRIMARY KEY IDENTITY,
	nombre nvarchar(255) NOT NULL CONSTRAINT UQ_medio_pago_nombre UNIQUE
)
GO

CREATE TABLE MAX_TURBO.factura (
	id int PRIMARY KEY IDENTITY,
	precio_total numeric(18,2) NOT NULL,
	medio_pago_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.medio_pago(id),
	tarjeta_credito_id int NULL FOREIGN KEY REFERENCES MAX_TURBO.tarjeta_credito(id),
	fecha_emision datetime NOT NULL CONSTRAINT DF_factura_fecha_emision DEFAULT CURRENT_TIMESTAMP,
	estadia_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.estadia(id)
)
GO

CREATE TABLE MAX_TURBO.factura_item (
	id int PRIMARY KEY IDENTITY,
	factura_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.factura(id),
	descripcion nvarchar(255) NOT NULL,
	precio_unitario numeric(18,2) NOT NULL,
	unidades smallint NOT NULL CONSTRAINT DF_factura_item_unidades DEFAULT 1
)
GO

-- Functions

CREATE FUNCTION MAX_TURBO.fn_get_random_numeric()
RETURNS numeric(18,0)
AS
BEGIN

  RETURN ABS(CHECKSUM(RAND())) % 18;
END

-- Stored Procedures

IF OBJECT_ID('MAX_TURBO.sp_create_cliente') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_cliente;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_cliente 
(
@Cliente_Pasaporte_Nro numeric(9),
@Cliente_Apellido nvarchar(255),
@Cliente_Nombre nvarchar(255),
@Cliente_Fecha_Nac datetime,
@Cliente_Mail nvarchar(255),
@Cliente_Dom_Calle nvarchar(255),
@Cliente_Nro_Calle numeric(9),
@Cliente_Piso numeric(9),
@Cliente_Depto nvarchar(50),
@Cliente_Nacionalidad nvarchar(255)
)
AS 
BEGIN 

	DECLARE @IdCliente AS INT;
	
	SELECT @IdCliente = id FROM MAX_TURBO.cliente WHERE 
	nombre = @Cliente_Nombre AND apellido = @Cliente_Apellido AND nro_documento = @Cliente_Pasaporte_Nro AND
	fecha_nacimiento = @Cliente_Fecha_Nac AND email = @Cliente_Mail AND direccion_calle = @Cliente_Dom_Calle
	AND direccion_nro = @Cliente_Nro_Calle AND direccion_piso = @Cliente_Piso AND direccion_depto = 
	@Cliente_Depto AND nacionalidad = @Cliente_Nacionalidad;

	IF @IdCliente IS NOT NULL
	BEGIN
	
	  RETURN @IdCliente;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.cliente (nombre, apellido, tipo_documento, nro_documento, fecha_nacimiento, email, direccion_calle, direccion_nro, direccion_piso, direccion_depto, nacionalidad) VALUES
	   (@Cliente_Nombre, @Cliente_Apellido, 'PASAPORTE', @Cliente_Pasaporte_Nro, @Cliente_Fecha_Nac, @Cliente_Mail, @Cliente_Dom_Calle, @Cliente_Nro_Calle, @Cliente_Piso, @Cliente_Depto, @Cliente_Nacionalidad)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_hotel') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_hotel;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_hotel 
(
@Hotel_Ciudad nvarchar(255),
@Hotel_Calle nvarchar(255),
@Hotel_Nro_Calle numeric(9),
@Hotel_CantEstrella numeric(9),
@Hotel_Recarga_Estrella numeric(9)
)
AS 
BEGIN 

	DECLARE @IdHotel AS INT;
	
	SELECT @IdHotel = id FROM MAX_TURBO.hotel WHERE 
	ciudad = @Hotel_Ciudad AND direccion_calle = @Hotel_Calle AND direccion_nro = @Hotel_Nro_Calle AND estrellas = 
	@Hotel_CantEstrella AND recargo_estrellas = @Hotel_Recarga_Estrella;

	IF @IdHotel IS NOT NULL
	BEGIN
	
	  RETURN @IdHotel;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.hotel (ciudad, direccion_calle, direccion_nro, estrellas, recargo_estrellas) VALUES
	   (@Hotel_Ciudad, @Hotel_Calle, @Hotel_Nro_Calle, @Hotel_CantEstrella, @Hotel_Recarga_Estrella)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_habitacion_tipo') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_habitacion_tipo;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_habitacion_tipo 
(
@Habitacion_Tipo_Codigo numeric(9),
@Habitacion_Tipo_Descripcion nvarchar(255),
@Habitacion_Tipo_Porcentual numeric(9)
)
AS 
BEGIN 

	DECLARE @IdTipoHabitacion AS INT;
	
	SELECT @IdTipoHabitacion = id FROM MAX_TURBO.tipo_habitacion WHERE 
	codigo = @Habitacion_Tipo_Codigo AND nombre = @Habitacion_Tipo_Descripcion AND porcentaje = @Habitacion_Tipo_Porcentual;

	IF @IdTipoHabitacion IS NOT NULL
	BEGIN
	
	  RETURN @IdTipoHabitacion;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.tipo_habitacion (codigo, nombre, porcentaje) VALUES
	   (@Habitacion_Tipo_Codigo, @Habitacion_Tipo_Descripcion, @Habitacion_Tipo_Porcentual)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_habitacion') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_habitacion;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_habitacion 
(
@IdHotel int,
@IdHabitacionTipo int,
@Habitacion_Numero numeric(9),
@Habitacion_Piso numeric(9),
@Habitacion_Frente nvarchar(50),
)
AS 
BEGIN 

	DECLARE @IdHabitacion AS INT;
	
	SELECT @IdHabitacion = id FROM MAX_TURBO.habitacion WHERE 
	hotel_id = @IdHotel AND tipo_habitacion_id = @IdHabitacionTipo AND numero = @Habitacion_Numero AND piso = @Habitacion_Piso 
	AND frente = @Habitacion_Frente;

	IF @IdHabitacion IS NOT NULL
	BEGIN
	
	  RETURN @IdHabitacion;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.habitacion (hotel_id, tipo_habitacion_id, numero, piso, frente) VALUES
	   (@IdHotel, @IdHabitacionTipo, @Habitacion_Numero, @Habitacion_Piso, @Habitacion_Frente)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_regimen') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_regimen;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_regimen 
(
@Regimen_Descripcion nvarchar(255),
@Regimen_Precio numeric(9)
)
AS 
BEGIN 

	DECLARE @IdRegimen AS INT;
	
	SELECT @IdRegimen = id FROM MAX_TURBO.regimen WHERE 
	descripcion = @ AND precio = @Regimen_Precio;

	IF @IdRegimen IS NOT NULL
	BEGIN
	
	  RETURN @IdRegimen;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.regimen (codigo, precio, descripcion) VALUES
	   (ABS(CHECKSUM(RAND())), @Regimen_Precio, @Regimen_Descripcion)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_hotel_regimen') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_hotel_regimen;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_hotel_regimen 
(
@IdHotel int, 
@IdRegimen int
)
AS 
BEGIN 

	IF NOT EXISTS(SELECT * FROM MAX_TURBO.hotel_regimen WHERE 
	hotel_id = @IdHotel AND regimen_id = @IdRegimen)
	BEGIN
	
	   INSERT INTO MAX_TURBO.hotel_regimen (hotel_id, regimen_id) VALUES
	   (@IdHotel, @IdRegimen)	
	END
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_reserva') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_reserva;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_reserva 
(
@IdHotel int, 
@IdRegimen int, 
@IdCliente int, 
@Reserva_Fecha_Inicio datetime,
@Reserva_Codigo numeric(9),
@Reserva_Cant_Noches numeric(9),
)
AS 
BEGIN 

	DECLARE @idReserva AS INT;
	
	SELECT @idReserva = id FROM MAX_TURBO.reserva WHERE 
	hotel_id = @IdHotel AND regimen_id = @IdRegimen AND cliente_id = @IdCliente AND
	fecha_desde = @Reserva_Fecha_Inicio AND codigo = @Reserva_Codigo AND fecha_hasta = DATEADD(Day, @Reserva_Cant_Noches, @Reserva_Fecha_Inicio);

	IF @idReserva IS NOT NULL
	BEGIN
	
	  RETURN @idReserva;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.reserva (estado_id, fecha_desde, fecha_hasta, regimen_id, usuario_id, cliente_id, codigo, hotel_id) VALUES
	   (1, @Reserva_Fecha_Inicio, DATEADD(Day, @Reserva_Cant_Noches, @Reserva_Fecha_Inicio), @IdRegimen, 1, @IdCliente, @Reserva_Codigo, @IdHotel)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_reserva_habitacion') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_reserva_habitacion;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_reserva_habitacion 
(
@IdReserva int, 
@IdHabitacion int
)
AS 
BEGIN 

	IF NOT EXISTS(SELECT * FROM MAX_TURBO.reserva_habitacion WHERE 
	reserva_id = @IdReserva AND habitacion_id = @IdHabitacion)
	BEGIN
	
	   INSERT INTO MAX_TURBO.reserva_habitacion (reserva_id, habitacion_id) VALUES
	   (@IdReserva, @IdHabitacion)	
	END
	END

END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_estadia') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_estadia;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_estadia 
(
@IdReserva int, 
@Estadia_Fecha_Inicio datetime,
@Estadia_Cant_Noches numeric(9),
)
AS 
BEGIN 

	DECLARE @IdEstadia AS INT;
	
	SELECT @IdEstadia = id FROM MAX_TURBO.estadia WHERE 
	reserva_id = @IdReserva AND ingreso_fecha = @Estadia_Fecha_Inicio AND egreso_fecha = DATEADD(Day, @Estadia_Cant_Noches, @Estadia_Fecha_Inicio);

	IF @IdEstadia IS NOT NULL
	BEGIN
	
	  RETURN @IdEstadia;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.estadia (reserva_id, ingreso_fecha, ingreso_usuario_id, egreso_fecha, egreso_usuario_id) VALUES
	   (@IdReserva, @Estadia_Fecha_Inicio, 1, DATEADD(Day, @Estadia_Cant_Noches, @Estadia_Fecha_Inicio), 1)
	 
		RETURN @@IDENTITY;
	END
END
GO



IF OBJECT_ID('MAX_TURBO.sp_create_consumible') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_consumible;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_consumible 
(
@Consumible_Codigo numeric(9),
@Consumible_Descripcion nvarchar(255),
@Consumible_Precio numeric(9)
)
AS 
BEGIN 

	DECLARE @IdConsumible AS INT;
	
	SELECT @IdConsumible = id FROM MAX_TURBO.consumible WHERE 
	nombre = @Consumible_Descripcion AND precio = @Consumible_Precio AND codigo = @Consumible_Codigo;

	IF @IdConsumible IS NOT NULL
	BEGIN
	
	  RETURN @IdConsumible;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.consumible (nombre, precio, codigo) VALUES
	   (@Consumible_Descripcion, @Consumible_Precio, @Consumible_Codigo)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_consumible_estadia') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_consumible_estadia;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_consumible_estadia 
(
@IdConsumible int, 
@IdEstadia int, 
@Item_Factura_Cantidad numeric(9)
)
AS 
BEGIN 

	IF NOT EXISTS(SELECT * FROM MAX_TURBO.consumible_estadia WHERE 
	consumible_id = @IdConsumible AND estadia_id = @IdEstadia AND unidades = @Item_Factura_Cantidad)
	BEGIN
	
	   INSERT INTO MAX_TURBO.consumible_estadia (consumible_id, estadia_id, unidades) VALUES
	   (@IdConsumible, @IdEstadia, @Item_Factura_Cantidad)	
	END
	END

END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_factura') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_factura;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_factura 
(
@IdReserva int, 
@Estadia_Fecha_Inicio datetime,
@Estadia_Cant_Noches numeric(9),
)
AS 
BEGIN 

	DECLARE @IdEstadia AS INT;
	
	SELECT @IdEstadia = id FROM MAX_TURBO.estadia WHERE 
	reserva_id = @IdReserva AND ingreso_fecha = @Estadia_Fecha_Inicio AND egreso_fecha = DATEADD(Day, @Estadia_Cant_Noches, @Estadia_Fecha_Inicio);

	IF @IdEstadia IS NOT NULL
	BEGIN
	
	  RETURN @IdEstadia;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.estadia (reserva_id, ingreso_fecha, ingreso_usuario_id, egreso_fecha, egreso_usuario_id) VALUES
	   (@IdReserva, @Estadia_Fecha_Inicio, 1, DATEADD(Day, @Estadia_Cant_Noches, @Estadia_Fecha_Inicio), 1)
	 
		RETURN @@IDENTITY;
	END
END
GO

IF OBJECT_ID('MAX_TURBO.sp_create_estadia') IS NOT NULL
    DROP PROCEDURE MAX_TURBO.sp_create_estadia;

GO
CREATE PROCEDURE MAX_TURBO.sp_create_estadia 
(
@IdReserva int, 
@Estadia_Fecha_Inicio datetime,
@Estadia_Cant_Noches numeric(9),
)
AS 
BEGIN 

	DECLARE @IdEstadia AS INT;
	
	SELECT @IdEstadia = id FROM MAX_TURBO.estadia WHERE 
	reserva_id = @IdReserva AND ingreso_fecha = @Estadia_Fecha_Inicio AND egreso_fecha = DATEADD(Day, @Estadia_Cant_Noches, @Estadia_Fecha_Inicio);

	IF @IdEstadia IS NOT NULL
	BEGIN
	
	  RETURN @IdEstadia;
	
	END
	ELSE
	BEGIN
	
	   INSERT INTO MAX_TURBO.estadia (reserva_id, ingreso_fecha, ingreso_usuario_id, egreso_fecha, egreso_usuario_id) VALUES
	   (@IdReserva, @Estadia_Fecha_Inicio, 1, DATEADD(Day, @Estadia_Cant_Noches, @Estadia_Fecha_Inicio), 1)
	 
		RETURN @@IDENTITY;
	END
END
GO

-- 2: Save master data
-- tables estado_reserva, medio_pago, funcionalidad, funcionalidad_rol, rol, usuario_rol, usuario
INSERT INTO MAX_TURBO.estado_reserva (nombre) VALUES 
('Reserva correcta'), ('Reserva modificada'), ('Reserva cancelada por Recepción'), 
('Reserva cancelada por Cliente'), ('Reserva cancelada por No-Show'), ('Reserva con ingreso')
GO




-- 3: Import Data
-- Maestra table row variables
DECLARE @Hotel_Ciudad nvarchar(255);
DECLARE @Hotel_Calle nvarchar(255);
DECLARE @Hotel_Nro_Calle numeric(9);
DECLARE @Hotel_CantEstrella numeric(9);
DECLARE @Hotel_Recarga_Estrella numeric(9);
DECLARE @Habitacion_Numero numeric(9);
DECLARE @Habitacion_Piso numeric(9);
DECLARE @Habitacion_Frente nvarchar(50);
DECLARE @Habitacion_Tipo_Codigo numeric(9);
DECLARE @Habitacion_Tipo_Descripcion nvarchar(255);
DECLARE @Habitacion_Tipo_Porcentual numeric(9);
DECLARE @Regimen_Descripcion nvarchar(255);
DECLARE @Regimen_Precio numeric(9);
DECLARE @Reserva_Fecha_Inicio datetime;
DECLARE @Reserva_Codigo numeric(9);
DECLARE @Reserva_Cant_Noches numeric(9);
DECLARE @Estadia_Fecha_Inicio datetime;
DECLARE @Estadia_Cant_Noches numeric(9);
DECLARE @Consumible_Codigo numeric(9);
DECLARE @Consumible_Descripcion nvarchar(255);
DECLARE @Consumible_Precio numeric(9);
DECLARE @Item_Factura_Cantidad numeric(9);
DECLARE @Item_Factura_Monto numeric(9);
DECLARE @Factura_Nro numeric(9);
DECLARE @Factura_Fecha datetime;
DECLARE @Factura_Total numeric(9);
DECLARE @Cliente_Pasaporte_Nro numeric(9);
DECLARE @Cliente_Apellido nvarchar(255);
DECLARE @Cliente_Nombre nvarchar(255);
DECLARE @Cliente_Fecha_Nac datetime;
DECLARE @Cliente_Mail nvarchar(255);
DECLARE @Cliente_Dom_Calle nvarchar(255);
DECLARE @Cliente_Nro_Calle numeric(9);
DECLARE @Cliente_Piso numeric(9);
DECLARE @Cliente_Depto nvarchar(50);
DECLARE @Cliente_Nacionalidad nvarchar(255);

-- Reference ids
DECLARE @IdCliente int;
DECLARE @IdFactura int;
DECLARE @IdItemFactura int;
DECLARE @IdConsumible int;
DECLARE @IdEstadia int;
DECLARE @IdReserva int;
DECLARE @IdRegimen int;
DECLARE @IdHabitacionTipo int;
DECLARE @IdHabitacion int;
DECLARE @IdHotel int;

DECLARE maestra_cursor CURSOR FOR SELECT * FROM gd_esquema.Maestra;

OPEN maestra_cursor;

-- Fetch first row
FETCH NEXT FROM maestra_cursor INTO @Hotel_Ciudad, @Hotel_Calle, @Hotel_Nro_Calle, @Hotel_CantEstrella, @Hotel_Recarga_Estrella, @Habitacion_Numero, @Habitacion_Piso, @Habitacion_Frente, @Habitacion_Tipo_Codigo, @Habitacion_Tipo_Descripcion, @Habitacion_Tipo_Porcentual, @Regimen_Descripcion, @Regimen_Precio, @Reserva_Fecha_Inicio, @Reserva_Codigo, @Reserva_Cant_Noches, @Estadia_Fecha_Inicio, @Estadia_Cant_Noches, @Consumible_Codigo, @Consumible_Descripcion, @Consumible_Precio, @Item_Factura_Cantidad, @Item_Factura_Monto, @Factura_Nro, @Factura_Fecha, @Factura_Total, @Cliente_Pasaporte_Nro, @Cliente_Apellido, @Cliente_Nombre, @Cliente_Fecha_Nac, @Cliente_Mail, @Cliente_Dom_Calle, @Cliente_Nro_Calle, @Cliente_Piso, @Cliente_Depto, @Cliente_Nacionalidad;

WHILE @@fetch_status = 0
BEGIN
	
	EXEC @IdCliente = MAX_TURBO.sp_create_cliente @Cliente_Pasaporte_Nro, @Cliente_Apellido, @Cliente_Nombre, @Cliente_Fecha_Nac, @Cliente_Mail, @Cliente_Dom_Calle, @Cliente_Nro_Calle, @Cliente_Piso, @Cliente_Depto, @Cliente_Nacionalidad;

	EXEC @IdHotel = MAX_TURBO.sp_create_hotel @Hotel_Ciudad, @Hotel_Calle, @Hotel_Nro_Calle, @Hotel_CantEstrella, @Hotel_Recarga_Estrella;

	EXEC @IdHabitacionTipo = MAX_TURBO.sp_create_habitacion_tipo @Habitacion_Tipo_Codigo, @Habitacion_Tipo_Descripcion, @Habitacion_Tipo_Porcentual;

	EXEC @IdHabitacion = MAX_TURBO.sp_create_habitacion @IdHotel, @IdHabitacionTipo, @Habitacion_Numero, @Habitacion_Piso, @Habitacion_Frente;
	
	EXEC @IdRegimen = MAX_TURBO.sp_create_regimen @Regimen_Descripcion, @Regimen_Precio;

	EXEC MAX_TURBO.sp_create_hotel_regimen @IdHotel, @IdRegimen;
	
	EXEC @IdReserva = MAX_TURBO.sp_create_reserva @IdHotel, @IdRegimen, @IdCliente, @Reserva_Fecha_Inicio, @Reserva_Codigo, @Reserva_Cant_Noches;

	EXEC MAX_TURBO.sp_create_reserva_habitacion @IdReserva, @IdHabitacion;

	EXEC @IdEstadia = MAX_TURBO.sp_create_estadia @IdReserva, @Estadia_Fecha_Inicio, @Estadia_Cant_Noches;

	EXEC MAX_TURBO.sp_create_estadia_cliente @IdEstadia, @IdCliente;
	
	EXEC @IdConsumible = MAX_TURBO.sp_create_consumible @Consumible_Codigo, @Consumible_Descripcion, @Consumible_Precio;

	EXEC MAX_TURBO.sp_create_consumible_estadia @IdConsumible, @IdEstadia, @Item_Factura_Cantidad;

	EXEC @IdFactura = MAX_TURBO.sp_create_factura @IdEstadia, @Factura_Nro, @Factura_Fecha, @Factura_Total;

	EXEC MAX_TURBO.sp_create_item_factura @IdFactura, @Item_Factura_Cantidad, @Item_Factura_Monto, @Consumible_Descripcion;

	-- Fetch next row
	FETCH NEXT FROM maestra_cursor INTO @Hotel_Ciudad, @Hotel_Calle, @Hotel_Nro_Calle, @Hotel_CantEstrella, @Hotel_Recarga_Estrella, @Habitacion_Numero, @Habitacion_Piso, @Habitacion_Frente, @Habitacion_Tipo_Codigo, @Habitacion_Tipo_Descripcion, @Habitacion_Tipo_Porcentual, @Regimen_Descripcion, @Regimen_Precio, @Reserva_Fecha_Inicio, @Reserva_Codigo, @Reserva_Cant_Noches, @Estadia_Fecha_Inicio, @Estadia_Cant_Noches, @Consumible_Codigo, @Consumible_Descripcion, @Consumible_Precio, @Item_Factura_Cantidad, @Item_Factura_Monto, @Factura_Nro, @Factura_Fecha, @Factura_Total, @Cliente_Pasaporte_Nro, @Cliente_Apellido, @Cliente_Nombre, @Cliente_Fecha_Nac, @Cliente_Mail, @Cliente_Dom_Calle, @Cliente_Nro_Calle, @Cliente_Piso, @Cliente_Depto, @Cliente_Nacionalidad;

END

CLOSE maestra_cursor;
DEALLOCATE maestra_cursor;
