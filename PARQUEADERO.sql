
-- LIMPIAR Y CREAR LA BASE DE DATOS DESDE CERO
DROP DATABASE IF EXISTS parqueadero;
CREATE DATABASE parqueadero CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE parqueadero;

-- ========================================================
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

-- ========================================================
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

-- ========================================================
-- TABLA: CELDAS

CREATE TABLE celdas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(20) NOT NULL UNIQUE,
  tipo VARCHAR(20) NOT NULL,
  estado VARCHAR(10) NOT NULL,
  ubicacion TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ========================================================
-- TABLA: MOVIMIENTOS

CREATE TABLE movimientos (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  vehiculo_id INT NOT NULL,
  celda_id INT NOT NULL,
  usuario_id INT NOT NULL,
  hora_entrada DATETIME NOT NULL,
  hora_salida DATETIME DEFAULT NULL,
  tipo_movimiento VARCHAR(10) NOT NULL,
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

-- ========================================================
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

-- ========================================================
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

-- ========================================================
-- INDICES ADICIONALES (RECOMENDADOS)

CREATE INDEX idx_vehiculos_placa ON vehiculos(placa);
CREATE INDEX idx_movimientos_hora_entrada ON movimientos(hora_entrada);
CREATE INDEX idx_movimientos_estado ON movimientos(estado);

-- ========================================================
-- DATOS DE PRUEBA (OPCIONAL)

INSERT INTO usuarios (nombre, email, password_hash, rol)
VALUES ('Administrador', 'admin@parqueadero.com', 'hash123', 'admin'),
       ('Operador1', 'operador1@parqueadero.com', 'hash456', 'operador');

INSERT INTO celdas (codigo, tipo, estado, ubicacion)
VALUES ('C-001','cubierta','libre','Nivel 1'),
       ('C-002','descubierta','libre','Nivel 1');

INSERT INTO vehiculos (placa, tipo, marca, modelo, propietario_id)
VALUES ('ABC123','carro','Toyota','Corolla', 2),
       ('XYZ987','moto','Yamaha','FZ', 2);