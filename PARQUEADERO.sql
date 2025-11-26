-- LIMPIAR Y CREAR LA BASE DE DATOS DESDE CERO

DROP DATABASE IF EXISTS parqueadero;
CREATE DATABASE parqueadero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE parqueadero;

-- ========================================================
-- TABLAS 
-- TABLA: USUARIOS

CREATE TABLE usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  email VARCHAR(200) NOT NULL UNIQUE,
  password_hash VARCHAR(200) NOT NULL,
  rol VARCHAR(20) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_usuarios_email ON usuarios(email);

-- TABLA: VEHICULOS

CREATE TABLE vehiculos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  placa VARCHAR(15) NOT NULL UNIQUE,
  tipo VARCHAR(10) NOT NULL,
  marca VARCHAR(100),
  modelo VARCHAR(100),
  propietario_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vehiculos_propietario FOREIGN KEY (propietario_id)
    REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX idx_vehiculos_placa ON vehiculos(placa);


-- TABLA: CELDAS

CREATE TABLE celdas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  tipo VARCHAR(20) NOT NULL,     -- cubierta / descubierta
  estado VARCHAR(10) NOT NULL,   -- libre / ocupada
  ubicacion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE INDEX idx_celdas_estado ON celdas(estado);
CREATE INDEX idx_celdas_tipo ON celdas(tipo);

-- TABLA: MOVIMIENTOS

CREATE TABLE movimientos (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  vehiculo_id INT NOT NULL,
  celda_id INT NOT NULL,
  usuario_id INT NOT NULL,
  hora_entrada DATETIME NOT NULL,
  hora_salida DATETIME DEFAULT NULL,
  tipo_movimiento VARCHAR(10) NOT NULL, -- entrada / salida
  tiempo_minutos INT DEFAULT NULL,
  monto DECIMAL(10,2) DEFAULT 0.00,
  estado VARCHAR(20) DEFAULT 'activo',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_mov_vehiculo FOREIGN KEY (vehiculo_id)
    REFERENCES vehiculos(id) ON DELETE RESTRICT,

  CONSTRAINT fk_mov_celda FOREIGN KEY (celda_id)
    REFERENCES celdas(id) ON DELETE RESTRICT,

  CONSTRAINT fk_mov_usuario FOREIGN KEY (usuario_id)
    REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE INDEX idx_movimientos_hora_entrada ON movimientos(hora_entrada);
CREATE INDEX idx_movimientos_estado ON movimientos(estado);

-- TABLA: NOVEDADES

CREATE TABLE novedades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  movimiento_id BIGINT NOT NULL,
  autor_id INT NOT NULL,
  descripcion TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT fk_nov_mov FOREIGN KEY (movimiento_id)
    REFERENCES movimientos(id) ON DELETE CASCADE,

  CONSTRAINT fk_nov_autor FOREIGN KEY (autor_id)
    REFERENCES usuarios(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- TABLA: PAGOS

CREATE TABLE pagos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  movimiento_id BIGINT DEFAULT NULL,
  usuario_id INT DEFAULT NULL,
  tipo_pago VARCHAR(20),
  monto DECIMAL(10,2) NOT NULL,
  fecha_pago TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  referencia VARCHAR(200),

  CONSTRAINT fk_pago_mov FOREIGN KEY (movimiento_id)
    REFERENCES movimientos(id) ON DELETE SET NULL,

  CONSTRAINT fk_pago_usuario FOREIGN KEY (usuario_id)
    REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- DATOS DE PRUEBA INICIALES 

INSERT INTO usuarios (nombre, email, password_hash, rol)
VALUES ('Administrador', 'admin@parqueadero.com', 'hash123', 'admin'),
       ('Operador1', 'operador1@parqueadero.com', 'hash456', 'operador');

INSERT INTO celdas (codigo, tipo, estado, ubicacion)
VALUES ('C-001','cubierta','libre','Nivel 1'),
       ('C-002','descubierta','libre','Nivel 1');

INSERT INTO vehiculos (placa, tipo, marca, modelo, propietario_id)
VALUES ('ABC123','carro','Toyota','Corolla', 2),
       ('XYZ987','moto','Yamaha','FZ', 2);

-- USUARIO ADICIONALES
INSERT INTO usuarios (nombre, email, password_hash, rol)
VALUES ('Operador2', 'operador2@parqueadero.com', 'hash789', 'operador'),
       ('Supervisor', 'supervisor@parqueadero.com', 'hash111', 'admin');

-- CELDAS ADICIONALES 
INSERT INTO celdas (codigo, tipo, estado, ubicacion)
VALUES ('C-003','cubierta','ocupada','Nivel 2'),
       ('C-004','descubierta','libre','Nivel 2'),
       ('C-005','cubierta','libre','Nivel 3');
       
-- VEHÍCULOS ADICIONALES
INSERT INTO vehiculos (placa, tipo, marca, modelo, propietario_id)
VALUES ('JKL321','carro','Mazda','3', 3),
       ('MNO555','moto','Honda','CB190', 4),
       ('PQR777','carro','Renault','Logan', 1);
 
 -- MOVIMIENTOS DE PRUEBA (ENTRADA)
 INSERT INTO movimientos (
  vehiculo_id, celda_id, usuario_id, hora_entrada, tipo_movimiento
)
VALUES (1, 3, 1, NOW(), 'entrada'),
       (2, 1, 2, NOW(), 'entrada');
       
  -- MOVIMIENTOS DE SALIDA 
 UPDATE movimientos
SET hora_salida = NOW(), tipo_movimiento = 'salida', tiempo_minutos = 45, monto = 5000
WHERE id = 1;

-- NOVEDADES (OPCIONAL PERO ÚTIL)
INSERT INTO novedades (movimiento_id, autor_id, descripcion)
VALUES (1, 1, 'Vehículo con pequeño rayón en puerta izquierda.');

-- PAGO DE EJEMPLO
INSERT INTO pagos (movimiento_id, usuario_id, tipo_pago, monto, referencia)
VALUES (1, 1, 'efectivo', 5000, 'Pago caja 1'),
       (2, 2, 'tarjeta', 7000, 'Voucher 889922');