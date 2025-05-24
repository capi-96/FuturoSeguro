<?php
session_start();
require_once "conexion.php";

if (!isset($_SESSION['usuario'])) {
    header("Location: index.php");
    exit();
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $conectar = new Conectar();
    $dbh = $conectar->Conexion();
    
    if ($dbh) {
        $stmt = $dbh->prepare("EXEC sp_crear_prestamo ?, ?, ?, ?");
        $stmt->execute([
            $_POST['socio_id'],
            $_POST['monto'],
            $_POST['tasa_interes']/100,
            $_POST['plazo_meses']
        ]);
        $msg = "Préstamo registrado correctamente.";
    } else {
        $msg = "Error de conexión.";
    }
}

// Obtener lista de socios para el dropdown
$conectar = new Conectar();
$dbh = $conectar->Conexion();
$socios = [];
if ($dbh) {
    $stmt = $dbh->query("SELECT id, nombre FROM Socios WHERE estado = 'ACTIVO'");
    $socios = $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Registrar Préstamo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
    <h2>Registrar Nuevo Préstamo</h2>

    <?php if (isset($msg)): ?>
        <div class="alert alert-info"><?= $msg ?></div>
    <?php endif; ?>

    <form method="POST" class="needs-validation" novalidate>
        <div class="mb-3">
            <label class="form-label">Socio</label>
            <select name="socio_id" class="form-select" required>
                <option value="">Seleccione un socio</option>
                <?php foreach ($socios as $socio): ?>
                    <option value="<?= $socio['id'] ?>"><?= $socio['nombre'] ?></option>
                <?php endforeach; ?>
            </select>
            <div class="invalid-feedback">
                Por favor seleccione un socio
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">Monto del Préstamo (Q)</label>
            <input type="number" step="0.01" min="0.01" name="monto" class="form-control" required>
            <div class="invalid-feedback">
                El monto debe ser mayor a 0
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">Tasa de Interés Anual (%)</label>
            <input type="number" step="0.01" min="0.01" max="100" name="tasa_interes" class="form-control" required>
            <div class="invalid-feedback">
                La tasa debe estar entre 0.01% y 100%
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">Plazo en Meses</label>
            <input type="number" min="1" max="120" name="plazo_meses" class="form-control" required>
            <div class="invalid-feedback">
                El plazo debe estar entre 1 y 120 meses
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Registrar Préstamo</button>
        <a href="index.php" class="btn btn-secondary">Cancelar</a>
        <a href="inicio.php" class="btn btn-secondary">Volver a Inicio</a>
    </form>
</body>
</html>
