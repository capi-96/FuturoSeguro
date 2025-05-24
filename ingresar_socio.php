<?php
session_start();
require_once "conexion.php";

if (!isset($_SESSION['usuario'])) {
    header("Location: index.php");
    exit();
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $nombre = $_POST['nombre'];
    $email = $_POST['email'];
    $fecha = $_POST['fecha_ingreso'];
    $estado = $_POST['estado'];

    $conectar = new Conectar();
    $dbh = $conectar->Conexion();

    if ($dbh) {
        $sql = "INSERT INTO Socios (nombre, email, fecha_ingreso, estado)
                VALUES (?, ?, ?, ?)";
        $stmt = $dbh->prepare($sql);
        $stmt->execute([$nombre, $email, $fecha, $estado]);

        // Registrar en la bitácora
        $bitacora = "INSERT INTO Bitacora (usuario, accion, tabla_afectada, id_registro)
                     VALUES (?, 'INSERTAR', 'Socios', ?)";
        $stmtBitacora = $dbh->prepare($bitacora);
        $stmtBitacora->execute([$_SESSION['usuario'], $dbh->lastInsertId()]);

        $msg = "Socio registrado correctamente.";
    } else {
        $msg = "Error de conexión.";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Ingresar Socio</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
    <h2>Ingresar Nuevo Socio</h2>

    <?php if (isset($msg)): ?>
        <div class="alert alert-info"><?= $msg ?></div>
    <?php endif; ?>

    <form method="POST">
        <div class="mb-3">
            <label class="form-label">Nombre</label>
            <input type="text" name="nombre" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Correo Electrónico</label>
            <input type="email" name="email" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Fecha de Ingreso</label>
            <input type="date" name="fecha_ingreso" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label">Estado</label>
            <select name="estado" class="form-select" required>
                <option value="ACTIVO">ACTIVO</option>
                <option value="INACTIVO">INACTIVO</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Guardar Socio</button>
        <a href="inicio.php" class="btn btn-secondary">Volver a Inicio</a>
    </form>
</body>
</html>
