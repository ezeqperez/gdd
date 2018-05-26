USE GD1C2018
GO
------------- CREACIÓN DE ESQUEMA --------------
CREATE SCHEMA MAX_TURBO
GO
------------- CREACIÓN DE TABLAS ---------------
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
	email nvarchar(255) NOT NULL CONSTRAINT UQ_cliente_email UNIQUE,
	telefono nvarchar(20),
	direccion_calle nvarchar(255),
	direccion_nro numeric(18,0),
	direccion_piso numeric(18,0),
	direccion_depto nvarchar(50),
	direccion_ciudad nvarchar(255),
	direccion_pais nvarchar(255),
	nacionalidad nvarchar(255),
	fecha_nacimiento datetime,
	CONSTRAINT UQ_cliente UNIQUE (tipo_documento, nro_documento)
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
	regimen_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.regimen(id),
	usuario_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.usuario(id),
	cliente_id int NOT NULL FOREIGN KEY REFERENCES MAX_TURBO.cliente(id),
	cantidad_personas tinyint CONSTRAINT DF_reserva_cantidad_personas DEFAULT 1
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

------------- FIN CREACIÓN DE TABLAS ---------------