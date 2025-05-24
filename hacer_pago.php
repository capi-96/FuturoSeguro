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
        $stmt = $dbh->prepare("EXEC sp_registrar_pago ?, ?");
        $stmt->execute([
            $_POST['prestamo_id'],
            $_POST['monto']
        ]);
        $msg = "Pago registrado correctamente.";
    } else {
        $msg = "Error de conexión.";
    }
}

// Obtener lista de préstamos activos
$conectar = new Conectar();
$dbh = $conectar->Conexion();
$prestamos = [];
if ($dbh) {
    $stmt = $dbh->query("SELECT p.id, s.nombre, p.monto, p.saldo_pendiente 
                         FROM Prestamos p 
                         JOIN Socios s ON p.socio_id = s.id 
                         WHERE p.estado = 'VIGENTE'");
    $prestamos = $stmt->fetchAll(PDO::FETCH_ASSOC);
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Registrar Pago</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">
    <h2>Registrar Nuevo Pago</h2>

    <?php if (isset($msg)): ?>
        <div class="alert alert-info"><?= $msg ?></div>
    <?php endif; ?>

    <form method="POST" class="needs-validation" novalidate>
        <div class="mb-3">
            <label class="form-label">Préstamo</label>
            <select name="prestamo_id" class="form-select" required>
                <option value="">Seleccione un préstamo</option>
                <?php foreach ($prestamos as $prestamo): ?>
                    <option value="<?= $prestamo['id'] ?>">
                        <?= $prestamo['nombre'] ?> - 
                        Préstamo: Q<?= number_format($prestamo['monto'], 2) ?> - 
                        Saldo: Q<?= number_format($prestamo['saldo_pendiente'], 2) ?>
                    </option>
                <?php endforeach; ?>
            </select>
            <div class="invalid-feedback">
                Por favor seleccione un préstamo
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label">Monto del Pago (Q)</label>
            <input type="number" step="0.01" min="0.01" name="monto" class="form-control" required>
            <div class="invalid-feedback">
                El monto debe ser mayor a 0
            </div>
        </div>
        <button type="submit" class="btn btn-primary">Registrar Pago</button>
        <a href="index.php" class="btn btn-secondary">Cancelar</a>
        <a href="inicio.php" class="btn btn-secondary">Volver a Inicio</a>
    </form>
</body>
</html>
